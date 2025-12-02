const std = @import("std");

const c_build_options: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
    "--std=c++11",
};

const zig_src_dir = "src/";

const opencv_modules = [_][]const u8{
    "core", "imgproc", "imgcodecs", "videoio",   "highgui", "video", "calib3d", "features2d", "objdetect",
    "ml",   "flann",   "photo",     "stitching", "gapi", "dnn"
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
            "asyncarray.cpp",
            "calib3d.cpp",
            "core.cpp",
            "dnn.cpp",
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
    zigcv_lib.linkSystemLibrary("z");

    zigcv_lib.linkSystemLibrary("opencv_bioinspired");
    zigcv_lib.linkSystemLibrary("opencv_calib3d");
    zigcv_lib.linkSystemLibrary("opencv_ccalib");
    zigcv_lib.linkSystemLibrary("opencv_core");
    zigcv_lib.linkSystemLibrary("opencv_datasets");
    zigcv_lib.linkSystemLibrary("opencv_dnn");
    zigcv_lib.linkSystemLibrary("opencv_dnn_objdetect");
    zigcv_lib.linkSystemLibrary("opencv_dnn_superres");
    zigcv_lib.linkSystemLibrary("opencv_dpm");
    zigcv_lib.linkSystemLibrary("opencv_features2d");
    zigcv_lib.linkSystemLibrary("opencv_flann");
    zigcv_lib.linkSystemLibrary("opencv_freetype");
    zigcv_lib.linkSystemLibrary("opencv_fuzzy");
    zigcv_lib.linkSystemLibrary("opencv_gapi");
    zigcv_lib.linkSystemLibrary("opencv_hfs");
    zigcv_lib.linkSystemLibrary("opencv_highgui");
    zigcv_lib.linkSystemLibrary("opencv_imgcodecs");
    zigcv_lib.linkSystemLibrary("opencv_imgproc");
    zigcv_lib.linkSystemLibrary("opencv_intensity_transform");
    zigcv_lib.linkSystemLibrary("opencv_line_descriptor");
    zigcv_lib.linkSystemLibrary("opencv_mcc");
    zigcv_lib.linkSystemLibrary("opencv_ml");
    zigcv_lib.linkSystemLibrary("opencv_objdetect");
    zigcv_lib.linkSystemLibrary("opencv_optflow");
    zigcv_lib.linkSystemLibrary("opencv_phase_unwrapping");
    zigcv_lib.linkSystemLibrary("opencv_photo");
    zigcv_lib.linkSystemLibrary("opencv_plot");
    zigcv_lib.linkSystemLibrary("opencv_quality");
    zigcv_lib.linkSystemLibrary("opencv_rapid");
    zigcv_lib.linkSystemLibrary("opencv_reg");
    zigcv_lib.linkSystemLibrary("opencv_rgbd");
    zigcv_lib.linkSystemLibrary("opencv_saliency");
    zigcv_lib.linkSystemLibrary("opencv_shape");
    zigcv_lib.linkSystemLibrary("opencv_signal");
    zigcv_lib.linkSystemLibrary("opencv_stereo");
    zigcv_lib.linkSystemLibrary("opencv_stitching");
    zigcv_lib.linkSystemLibrary("opencv_structured_light");
    zigcv_lib.linkSystemLibrary("opencv_superres");
    zigcv_lib.linkSystemLibrary("opencv_surface_matching");
    zigcv_lib.linkSystemLibrary("opencv_text");
    zigcv_lib.linkSystemLibrary("opencv_video");
    zigcv_lib.linkSystemLibrary("opencv_videoio");
    zigcv_lib.linkSystemLibrary("opencv_videostab");
    zigcv_lib.linkSystemLibrary("opencv_xobjdetect");

    zigcv_lib.linkSystemLibrary("opencv_aruco");
    zigcv_lib.linkSystemLibrary("opencv_bgsegm");
    zigcv_lib.linkSystemLibrary("opencv_face");
    zigcv_lib.linkSystemLibrary("opencv_img_hash");
    zigcv_lib.linkSystemLibrary("opencv_tracking");
    zigcv_lib.linkSystemLibrary("opencv_wechat_qrcode");
    zigcv_lib.linkSystemLibrary("opencv_xfeatures2d");
    zigcv_lib.linkSystemLibrary("opencv_ximgproc");
    zigcv_lib.linkSystemLibrary("opencv_xphoto");

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
    unit_tests.linkLibrary(zigcv_lib);
    unit_tests.linkLibCpp();

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

    const configure_cmd = b.addSystemCommand(&.{ cmake_bin, "-B" });
    const build_work_dir = configure_cmd.addOutputDirectoryArg("build_work");

    const opencv_dep = b.dependency("opencv", .{});
    const opencv_path = opencv_dep.path("");
    const opencv_source_include = opencv_dep.path("include");
    const opencv_modules_dir = opencv_dep.path("modules");

    const opencv_contrib_dep = b.dependency("opencv_contrib", .{});
    const opencv_contrib_modules_dir = opencv_contrib_dep.path("modules");

    configure_cmd.addArg("-S");
    configure_cmd.addDirectoryArg(opencv_path);

    configure_cmd.setName("Running OpenCV's cmake --configure");
    configure_cmd.addPrefixedDirectoryArg("-DOPENCV_EXTRA_MODULES_PATH=", opencv_contrib_modules_dir);
    configure_cmd.addArgs(&.{
        "-DCMAKE_BUILD_TYPE=RELEASE",
        "-DWITH_IPP=OFF",
        "-DCMAKE_C_COMPILER=gcc",
        "-DCMAKE_CXX_COMPILER=g++",
        "-DCMAKE_CXX_STANDARD=17",
        "-DOPENCV_ENABLE_NONFREE=ON",
        "-DWITH_JASPER=OFF",
        "-DWITH_TBB=ON",
        "-DBUILD_DOCS=OFF",
        "-DBUILD_EXAMPLES=OFF",
        "-DBUILD_TESTS=OFF",
        "-DBUILD_PERF_TESTS=OFF",
        "-DBUILD_APPS=OFF",
        "-DBUILD_opencv_apps=OFF",
        "-DBUILD_opencv_java=NO",
        "-DBUILD_opencv_python=NO",
        "-DBUILD_opencv_python2=NO",
        "-DBUILD_opencv_python3=NO",
        "-DOPENCV_GENERATE_PKGCONFIG=OFF",
    });

    configure_cmd.expectExitCode(0);

    const cpu_count = std.Thread.getCpuCount() catch 1;
    const num_cores = b.fmt("{d}", .{cpu_count});

    const build_cmd = b.addSystemCommand(&.{ cmake_bin, "--build" });
    build_cmd.setName("Compiling OpenCV with zig");
    build_cmd.addDirectoryArg(build_work_dir);
    build_cmd.addArgs(&.{ "-j", num_cores });
    build_cmd.step.dependOn(&configure_cmd.step);
    build_cmd.expectExitCode(0);

    // const install_cmd = b.addSystemCommand(&.{ cmake_bin, "--install" });
    // install_cmd.addDirectoryArg(build_work_dir);
    // install_cmd.step.dependOn(&build_cmd.step);
    // install_cmd.expectExitCode(0);

    return .{
        .build_step = build_cmd,
        .source_include_dir = opencv_source_include,
        .modules_dir = opencv_modules_dir,
        .contrib_modules_dir = opencv_contrib_modules_dir,
        .build_include_dir = build_work_dir.path(b, ""),
        .lib_dir = build_work_dir.path(b, "lib"),
    };
}
