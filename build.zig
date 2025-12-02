const std = @import("std");

const c_build_options: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
    "--std=c++11",
};

const zig_src_dir = "src/";

const opencv_modules = [_][]const u8{
    "core", "imgproc", "imgcodecs", "videoio",   "highgui", "video", "calib3d", "features2d", "objdetect",
    "ml",   "flann",   "photo",     "stitching", "gapi"
};

const opencv_contrib_modules = [_][]const u8{
    "aruco",         "bgsegm",      "face",     "img_hash", "tracking",
    "wechat_qrcode", "xfeatures2d", "ximgproc", "xphoto",   "freetype",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gocv_dep = b.dependency("gocv", .{});
    const gocv_src_dir = gocv_dep.path("");
    const gocv_contrib_dir = gocv_dep.path("contrib");

    const opencv_build = buildOpenCVStep(b);

    var zigcv = b.addModule("root", .{
        .root_source_file = b.path("src/zigcv.zig"),
        .link_libcpp = true,
    });
    zigcv.addIncludePath(gocv_src_dir); // OpenCV C bindings base
    zigcv.addIncludePath(gocv_contrib_dir); // OpenCV contrib C bindings
    zigcv.addIncludePath(b.path(zig_src_dir)); // Our glue header
    zigcv.addIncludePath(opencv_build.source_include_dir); // OpenCV source headers
    zigcv.addIncludePath(opencv_build.build_include_dir); // OpenCV generated headers

    // Add module include paths
    for (opencv_modules) |module| {
        const module_include = opencv_build.modules_dir.path(b, b.fmt("{s}/include", .{module}));
        zigcv.addIncludePath(module_include);
    }

    // Add contrib module include paths
    for (opencv_contrib_modules) |module| {
        const module_include = opencv_build.contrib_modules_dir.path(b, b.fmt("{s}/include", .{module}));
        zigcv.addIncludePath(module_include);
    }

    const zigcv_lib = b.addLibrary(.{
        .name = "zigcv",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = true,
        }),
    });

    zigcv_lib.step.dependOn(&opencv_build.build_step.step);

    zigcv_lib.addIncludePath(gocv_src_dir); // OpenCV C bindings base
    zigcv_lib.addIncludePath(gocv_contrib_dir); // OpenCV contrib C bindings
    zigcv_lib.addIncludePath(b.path(zig_src_dir)); // Our glue header
    zigcv_lib.addIncludePath(opencv_build.source_include_dir); // OpenCV source headers
    zigcv_lib.addIncludePath(opencv_build.build_include_dir); // OpenCV generated headers (cvconfig.h, etc.)

    // Add module include paths
    for (opencv_modules) |module| {
        const module_include = opencv_build.modules_dir.path(b, b.fmt("{s}/include", .{module}));
        zigcv_lib.addIncludePath(module_include);
    }

    // Add contrib module include paths
    for (opencv_contrib_modules) |module| {
        const module_include = opencv_build.contrib_modules_dir.path(b, b.fmt("{s}/include", .{module}));
        zigcv_lib.addIncludePath(module_include);
    }

    zigcv_lib.addLibraryPath(opencv_build.lib_dir); // OpenCV libraries

    zigcv_lib.addCSourceFile(.{
        .file = b.path("src/core/zig_core.cpp"),
        .flags = c_build_options,
    });

    zigcv_lib.addCSourceFiles(.{
        .files = &.{
            "aruco.cpp",
            "calib3d.cpp",
            "core.cpp",
            "features2d.cpp",
            "highgui.cpp",
            "imgcodecs.cpp",
            "imgproc.cpp",
            "objdetect.cpp",
            "persistence_filenode.cpp",
            "persistence_filestorage.cpp",
            "photo.cpp",
            "svd.cpp",
            "version.cpp",
            "video.cpp",
            "videoio.cpp",
        },
        .root = gocv_dep.path(""),
        .flags = c_build_options,
    });

    zigcv_lib.addCSourceFiles(.{
        .files = &.{
            "bgsegm.cpp",
            "face.cpp",
            "freetype.cpp",
            "img_hash.cpp",
            "tracking.cpp",
            "wechat_qrcode.cpp",
            "xfeatures2d.cpp",
            "ximgproc.cpp",
            "xphoto.cpp",
        },
        .root = gocv_contrib_dir,
        .flags = c_build_options,
    });

    zigcv_lib.linkLibCpp();
    // Note: OpenCV libraries are not linked here to avoid embedding shared library
    // references in the static library. They must be linked by executables that use zigcv.

    b.installArtifact(zigcv_lib);

    // ---- Unit tests ---------------------------------------------------------
    const unit_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/zigcv.zig"),
        .target = target,
        .optimize = optimize,
    }) });

    unit_tests.addIncludePath(gocv_src_dir); // OpenCV C bindings base
    unit_tests.addIncludePath(gocv_contrib_dir); // OpenCV contrib C bindings
    unit_tests.addIncludePath(b.path(zig_src_dir)); // Our glue header
    unit_tests.addIncludePath(opencv_build.source_include_dir); // OpenCV source headers
    unit_tests.addIncludePath(opencv_build.build_include_dir); // OpenCV generated headers

    // Add module include paths
    for (opencv_modules) |module| {
        const module_include = opencv_build.modules_dir.path(b, b.fmt("{s}/include", .{module}));
        unit_tests.addIncludePath(module_include);
    }

    // Add contrib module include paths
    for (opencv_contrib_modules) |module| {
        const module_include = opencv_build.contrib_modules_dir.path(b, b.fmt("{s}/include", .{module}));
        unit_tests.addIncludePath(module_include);
    }

    unit_tests.addLibraryPath(opencv_build.lib_dir);
    unit_tests.addRPath(opencv_build.lib_dir);
    unit_tests.linkLibrary(zigcv_lib);
    unit_tests.linkLibCpp();
    unit_tests.linkSystemLibrary("z");

    // Link OpenCV libraries directly to the test executable
    unit_tests.linkSystemLibrary("opencv_bioinspired");
    unit_tests.linkSystemLibrary("opencv_calib3d");
    unit_tests.linkSystemLibrary("opencv_ccalib");
    unit_tests.linkSystemLibrary("opencv_core");
    unit_tests.linkSystemLibrary("opencv_datasets");
    unit_tests.linkSystemLibrary("opencv_dnn");
    unit_tests.linkSystemLibrary("opencv_dnn_objdetect");
    unit_tests.linkSystemLibrary("opencv_dnn_superres");
    unit_tests.linkSystemLibrary("opencv_dpm");
    unit_tests.linkSystemLibrary("opencv_features2d");
    unit_tests.linkSystemLibrary("opencv_flann");
    unit_tests.linkSystemLibrary("opencv_freetype");
    unit_tests.linkSystemLibrary("opencv_fuzzy");
    unit_tests.linkSystemLibrary("opencv_gapi");
    unit_tests.linkSystemLibrary("opencv_hfs");
    unit_tests.linkSystemLibrary("opencv_highgui");
    unit_tests.linkSystemLibrary("opencv_imgcodecs");
    unit_tests.linkSystemLibrary("opencv_imgproc");
    unit_tests.linkSystemLibrary("opencv_intensity_transform");
    unit_tests.linkSystemLibrary("opencv_line_descriptor");
    unit_tests.linkSystemLibrary("opencv_mcc");
    unit_tests.linkSystemLibrary("opencv_ml");
    unit_tests.linkSystemLibrary("opencv_objdetect");
    unit_tests.linkSystemLibrary("opencv_optflow");
    unit_tests.linkSystemLibrary("opencv_phase_unwrapping");
    unit_tests.linkSystemLibrary("opencv_photo");
    unit_tests.linkSystemLibrary("opencv_plot");
    unit_tests.linkSystemLibrary("opencv_quality");
    unit_tests.linkSystemLibrary("opencv_rapid");
    unit_tests.linkSystemLibrary("opencv_reg");
    unit_tests.linkSystemLibrary("opencv_rgbd");
    unit_tests.linkSystemLibrary("opencv_saliency");
    unit_tests.linkSystemLibrary("opencv_shape");
    unit_tests.linkSystemLibrary("opencv_signal");
    unit_tests.linkSystemLibrary("opencv_stereo");
    unit_tests.linkSystemLibrary("opencv_stitching");
    unit_tests.linkSystemLibrary("opencv_structured_light");
    unit_tests.linkSystemLibrary("opencv_superres");
    unit_tests.linkSystemLibrary("opencv_surface_matching");
    unit_tests.linkSystemLibrary("opencv_text");
    unit_tests.linkSystemLibrary("opencv_video");
    unit_tests.linkSystemLibrary("opencv_videoio");
    unit_tests.linkSystemLibrary("opencv_videostab");
    unit_tests.linkSystemLibrary("opencv_xobjdetect");
    unit_tests.linkSystemLibrary("opencv_aruco");
    unit_tests.linkSystemLibrary("opencv_bgsegm");
    unit_tests.linkSystemLibrary("opencv_face");
    unit_tests.linkSystemLibrary("opencv_img_hash");
    unit_tests.linkSystemLibrary("opencv_tracking");
    unit_tests.linkSystemLibrary("opencv_wechat_qrcode");
    unit_tests.linkSystemLibrary("opencv_xfeatures2d");
    unit_tests.linkSystemLibrary("opencv_ximgproc");
    unit_tests.linkSystemLibrary("opencv_xphoto");

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

const OpenCVBuild = struct {
    build_step: *std.Build.Step.Run,
    source_include_dir: std.Build.LazyPath,
    modules_dir: std.Build.LazyPath,
    contrib_modules_dir: std.Build.LazyPath,
    build_include_dir: std.Build.LazyPath,
    lib_dir: std.Build.LazyPath,
};

fn buildOpenCVStep(b: *std.Build) OpenCVBuild {
    const cmake_bin = b.findProgram(&.{"cmake"}, &.{}) catch @panic("Could not find cmake");

    const opencv_dep = b.dependency("opencv", .{});
    const opencv_path = opencv_dep.path("");
    const opencv_source_include = opencv_dep.path("include");
    const opencv_modules_dir = opencv_dep.path("modules");

    const opencv_contrib_dep = b.dependency("opencv_contrib", .{});
    const opencv_contrib_modules_dir = opencv_contrib_dep.path("modules");

    const configure_cmd = b.addSystemCommand(&.{ cmake_bin, "-B" });
    configure_cmd.setName("Running OpenCV's cmake --configure");
    const build_work_dir = configure_cmd.addOutputDirectoryArg("build_work");

    // Use environment variables instead of CMake compiler flags
    configure_cmd.setEnvironmentVariable("CC", "zig cc");
    configure_cmd.setEnvironmentVariable("CXX", "zig c++");

    configure_cmd.addArgs(&.{
        "-D",
        "CMAKE_BUILD_TYPE=RELEASE",
        "-D",
        "WITH_IPP=OFF",
        "-D",
        "CMAKE_CXX_STANDARD=17",
        "-D",
        "CMAKE_LINK_DEPENDS_NO_SHARED=ON",
        "-D",
        "CMAKE_CXX_FLAGS=-isystem-after /usr/include",
        "-D",
        "CMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs",
        "-D",
        "CMAKE_ASM_FLAGS=",
        "-D",
        "PNG_ARM_NEON_OPT=0",
        "-D",
        "BUILD_PNG=OFF",
        "-D",
    });
    configure_cmd.addPrefixedDirectoryArg("OPENCV_EXTRA_MODULES_PATH=", opencv_contrib_modules_dir);
    configure_cmd.addArgs(&.{
        "-D",
        "OPENCV_ENABLE_NONFREE=ON",
        "-D",
        "WITH_JASPER=OFF",
        "-D",
        "WITH_OPENEXR=OFF",
        "-D",
        "WITH_TBB=ON",
        "-D",
        "BUILD_DOCS=OFF",
        "-D",
        "BUILD_EXAMPLES=OFF",
        "-D",
        "BUILD_TESTS=OFF",
        "-D",
        "BUILD_PERF_TESTS=OFF",
        "-D",
        "BUILD_APPS=OFF",
        "-D",
        "BUILD_opencv_apps=OFF",
        "-D",
        "BUILD_opencv_dnn=OFF",
        "-D",
        "BUILD_opencv_java=NO",
        "-D",
        "BUILD_opencv_python=NO",
        "-D",
        "BUILD_opencv_python2=NO",
        "-D",
        "BUILD_opencv_python3=NO",
        "-D",
        "OPENCV_GENERATE_PKGCONFIG=OFF",
    });
    configure_cmd.addDirectoryArg(opencv_path);
    configure_cmd.expectExitCode(0);

    const cpu_count = std.Thread.getCpuCount() catch 1;
    const num_cores = b.fmt("{d}", .{cpu_count});

    const build_cmd = b.addSystemCommand(&.{ cmake_bin, "--build" });
    build_cmd.setName("Compiling OpenCV with zig");
    build_cmd.addDirectoryArg(build_work_dir);
    build_cmd.addArgs(&.{ "-j", num_cores });
    build_cmd.step.dependOn(&configure_cmd.step);
    build_cmd.expectExitCode(0);

    return .{
        .build_step = build_cmd,
        .source_include_dir = opencv_source_include,
        .modules_dir = opencv_modules_dir,
        .contrib_modules_dir = opencv_contrib_modules_dir,
        .build_include_dir = build_work_dir.path(b, ""),
        .lib_dir = build_work_dir.path(b, "lib"),
    };
}
