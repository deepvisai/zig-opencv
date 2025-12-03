const std = @import("std");

const c_build_options: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
    "-std=c++17",
};

const zig_src_dir = "src/";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ===========================================================================
    // Read build options from dependency args
    // ===========================================================================

    // Performance
    const enable_intrinsics = b.option(bool, "enable_intrinsics", "Enable SIMD intrinsics") orelse true;
    const enable_memalign = b.option(bool, "enable_memalign", "Enable aligned memory allocation") orelse true;
    const cpu_baseline = b.option([]const u8, "cpu_baseline", "Required CPU features") orelse "SSE4_2";
    const cpu_dispatch = b.option([]const u8, "cpu_dispatch", "Runtime dispatched features") orelse "AVX,AVX2";
    const fast_math = b.option(bool, "fast_math", "Enable fast math") orelse true;
    const lto = b.option(bool, "lto", "Link-Time Optimization") orelse false;

    // Threading
    const with_tbb = b.option(bool, "with_tbb", "Intel TBB") orelse false;
    const with_openmp = b.option(bool, "with_openmp", "OpenMP") orelse false;
    const with_pthreads = b.option(bool, "with_pthreads", "pthreads") orelse true;

    // GPU
    const with_cuda = b.option(bool, "with_cuda", "CUDA") orelse false;
    const with_opencl = b.option(bool, "with_opencl", "OpenCL") orelse false;
    const with_vulkan = b.option(bool, "with_vulkan", "Vulkan") orelse false;

    // Image Formats
    const with_jpeg = b.option(bool, "with_jpeg", "JPEG") orelse true;
    const with_png = b.option(bool, "with_png", "PNG") orelse true;
    const with_tiff = b.option(bool, "with_tiff", "TIFF") orelse true;
    const with_webp = b.option(bool, "with_webp", "WebP") orelse true;
    const with_openexr = b.option(bool, "with_openexr", "OpenEXR") orelse false;
    const with_jasper = b.option(bool, "with_jasper", "JPEG2000") orelse false;
    const build_jpeg = b.option(bool, "build_jpeg", "Build bundled libjpeg") orelse true;
    const build_png = b.option(bool, "build_png", "Build bundled libpng") orelse true;
    const build_tiff = b.option(bool, "build_tiff", "Build bundled libtiff") orelse true;

    // Video
    const with_ffmpeg = b.option(bool, "with_ffmpeg", "FFmpeg") orelse false;
    const with_gstreamer = b.option(bool, "with_gstreamer", "GStreamer") orelse false;
    const with_v4l = b.option(bool, "with_v4l", "Video4Linux") orelse true;

    // GUI
    const with_gtk = b.option(bool, "with_gtk", "GTK") orelse false;
    const with_qt = b.option(bool, "with_qt", "Qt") orelse false;
    const build_highgui = b.option(bool, "build_highgui", "highgui module") orelse true;

    // Math
    const with_eigen = b.option(bool, "with_eigen", "Eigen") orelse true;
    const with_lapack = b.option(bool, "with_lapack", "LAPACK") orelse false;

    // External
    const with_ipp = b.option(bool, "with_ipp", "Intel IPP") orelse false;

    // Features
    const enable_nonfree = b.option(bool, "enable_nonfree", "Non-free algorithms") orelse true;

    // Modules
    const build_contrib = b.option(bool, "build_contrib", "Contrib modules") orelse true;
    const build_dnn = b.option(bool, "build_dnn", "DNN module") orelse false;
    const build_ml = b.option(bool, "build_ml", "ML module") orelse true;
    const build_objdetect = b.option(bool, "build_objdetect", "Object detection module") orelse true;

    // Development
    const build_tests = b.option(bool, "build_tests", "Tests") orelse false;
    const build_examples = b.option(bool, "build_examples", "Examples") orelse false;
    const build_docs = b.option(bool, "build_docs", "Documentation") orelse false;

    // ===========================================================================
    // Get dependencies
    // ===========================================================================

    const opencv_dep = b.dependency("opencv", .{});
    const opencv_path = opencv_dep.path("");
    const opencv_source_include = opencv_dep.path("include");
    const opencv_modules_dir = opencv_dep.path("modules");

    const opencv_contrib_dep = b.dependency("opencv_contrib", .{});
    const opencv_contrib_modules_dir = opencv_contrib_dep.path("modules");

    // ===========================================================================
    // Build OpenCV with CMake
    // ===========================================================================

    const cmake_bin = b.findProgram(&.{"cmake"}, &.{}) catch @panic("cmake not found");

    // Configure
    const configure_cmd = b.addSystemCommand(&.{ cmake_bin, "-B" });
    configure_cmd.setName("Configure OpenCV");
    const opencv_build_dir = configure_cmd.addOutputDirectoryArg("opencv_build");

    configure_cmd.setEnvironmentVariable("CC", "zig cc");
    configure_cmd.setEnvironmentVariable("CXX", "zig c++");

    // Core settings
    configure_cmd.addArgs(&.{
        "-DCMAKE_BUILD_SHARED_LIBS=OFF",
        "-DCMAKE_BUILD_TYPE=RELEASE",
        "-DCMAKE_CXX_STANDARD=17",
        "-DCMAKE_CXX_FLAGS=-w",
        "-DCMAKE_C_FLAGS=-w",
        "-DCMAKE_DEPENDS_USE_COMPILER=OFF",
        "-DBUILD_SHARED_LIBS=OFF",
        "-DCMAKE_NINJA_FORCE_RESPONSE_FILE=OFF",
        "-DCMAKE_DEPENDS_IN_PROJECT_ONLY=ON",

        // Suppress warnings
        "-Wno-dev",
        "-Wno-deprecated",
        "--no-warn-unused-cli",
    });

    // Performance - direct mapping
    addBoolFlag(b, configure_cmd, "CV_ENABLE_INTRINSICS", enable_intrinsics);
    addBoolFlag(b, configure_cmd, "OPENCV_ENABLE_MEMALIGN", enable_memalign);
    addStringFlag(b, configure_cmd, "CPU_BASELINE", cpu_baseline);
    addStringFlag(b, configure_cmd, "CPU_DISPATCH", cpu_dispatch);
    addBoolFlag(b, configure_cmd, "ENABLE_FAST_MATH", fast_math);
    addBoolFlag(b, configure_cmd, "ENABLE_LTO", lto);

    // Threading
    addBoolFlag(b, configure_cmd, "WITH_TBB", with_tbb);
    addBoolFlag(b, configure_cmd, "WITH_OPENMP", with_openmp);
    addBoolFlag(b, configure_cmd, "WITH_PTHREADS_PF", with_pthreads);

    // GPU
    addBoolFlag(b, configure_cmd, "WITH_CUDA", with_cuda);
    addBoolFlag(b, configure_cmd, "WITH_OPENCL", with_opencl);
    addBoolFlag(b, configure_cmd, "WITH_VULKAN", with_vulkan);

    // Image formats
    addBoolFlag(b, configure_cmd, "WITH_JPEG", with_jpeg);
    addBoolFlag(b, configure_cmd, "WITH_PNG", with_png);
    addBoolFlag(b, configure_cmd, "WITH_TIFF", with_tiff);
    addBoolFlag(b, configure_cmd, "WITH_WEBP", with_webp);
    addBoolFlag(b, configure_cmd, "WITH_OPENEXR", with_openexr);
    addBoolFlag(b, configure_cmd, "WITH_JASPER", with_jasper);
    addBoolFlag(b, configure_cmd, "BUILD_JPEG", build_jpeg);
    addBoolFlag(b, configure_cmd, "BUILD_PNG", build_png);
    addBoolFlag(b, configure_cmd, "BUILD_TIFF", build_tiff);

    // Video
    addBoolFlag(b, configure_cmd, "WITH_FFMPEG", with_ffmpeg);
    addBoolFlag(b, configure_cmd, "WITH_GSTREAMER", with_gstreamer);
    addBoolFlag(b, configure_cmd, "WITH_V4L", with_v4l);

    // GUI
    addBoolFlag(b, configure_cmd, "WITH_GTK", with_gtk);
    addBoolFlag(b, configure_cmd, "WITH_QT", with_qt);
    addBoolFlag(b, configure_cmd, "BUILD_opencv_highgui", build_highgui);

    // Math
    addBoolFlag(b, configure_cmd, "WITH_EIGEN", with_eigen);
    addBoolFlag(b, configure_cmd, "WITH_LAPACK", with_lapack);

    // External
    addBoolFlag(b, configure_cmd, "WITH_IPP", with_ipp);

    // Features
    addBoolFlag(b, configure_cmd, "OPENCV_ENABLE_NONFREE", enable_nonfree);

    // Modules
    addBoolFlag(b, configure_cmd, "BUILD_opencv_dnn", build_dnn);
    addBoolFlag(b, configure_cmd, "BUILD_opencv_ml", build_ml);
    addBoolFlag(b, configure_cmd, "BUILD_opencv_objdetect", build_objdetect);

    // Contrib
    if (build_contrib) {
        configure_cmd.addArgs(&.{"-D"});
        configure_cmd.addPrefixedDirectoryArg("OPENCV_EXTRA_MODULES_PATH=", opencv_contrib_modules_dir);
    }

    // Development
    addBoolFlag(b, configure_cmd, "BUILD_TESTS", build_tests);
    addBoolFlag(b, configure_cmd, "BUILD_PERF_TESTS", false);
    addBoolFlag(b, configure_cmd, "BUILD_EXAMPLES", build_examples);
    addBoolFlag(b, configure_cmd, "BUILD_DOCS", build_docs);

    // Always disable
    configure_cmd.addArgs(&.{
        "-DBUILD_opencv_apps=OFF",
        "-DBUILD_opencv_java=OFF",
        "-DBUILD_opencv_python2=OFF",
        "-DBUILD_opencv_python3=OFF",
        "-DBUILD_opencv_python_bindings_generator=OFF",
        "-DOPENCV_GENERATE_PKGCONFIG=OFF",
        "-DPYTHON3_EXECUTABLE=",
        "-DPYTHON_EXECUTABLE=",
        "-DPYTHON3_NUMPY_INCLUDE_DIRS=",
    });

    configure_cmd.addDirectoryArg(opencv_path);
    configure_cmd.expectExitCode(0);

    // Build
    const cpu_count = std.Thread.getCpuCount() catch 1;
    const build_cmd = b.addSystemCommand(&.{ cmake_bin, "--build" });
    build_cmd.setName("Build OpenCV");
    build_cmd.addDirectoryArg(opencv_build_dir);
    build_cmd.addArgs(&.{ "-j", b.fmt("{d}", .{cpu_count}) });
    build_cmd.step.dependOn(&configure_cmd.step);
    build_cmd.expectExitCode(0);

    // Paths after build
    const opencv_include_dir = opencv_build_dir.path(b, "");
    const opencv_lib_dir = opencv_build_dir.path(b, "lib");

    // ===========================================================================
    // Create zigcv module
    // ===========================================================================

    const zigcv_module = b.addModule("zigcv", .{
        .root_source_file = b.path("src/zigcv.zig"),
        .link_libcpp = true,
    });

    zigcv_module.addIncludePath(b.path("src"));
    zigcv_module.addIncludePath(opencv_source_include);
    zigcv_module.addIncludePath(opencv_include_dir);

    const opencv_modules = [_][]const u8{ "core", "imgproc", "imgcodecs", "videoio", "highgui", "video", "calib3d", "features2d", "objdetect", "ml", "flann", "photo", "stitching", "gapi" };

    for (opencv_modules) |module| {
        zigcv_module.addIncludePath(opencv_modules_dir.path(b, b.fmt("{s}/include", .{module})));
    }

    if (build_contrib) {
        const contrib_modules = [_][]const u8{
            "aruco",         "bgsegm",      "face",     "img_hash", "tracking",
            "wechat_qrcode", "xfeatures2d", "ximgproc", "xphoto",   "freetype",
        };
        for (contrib_modules) |module| {
            zigcv_module.addIncludePath(opencv_contrib_modules_dir.path(b, b.fmt("{s}/include", .{module})));
        }
    }

    // ===========================================================================
    // Create zigcv static library
    // ===========================================================================

    const zigcv_lib = b.addLibrary(.{
        .name = "zigcv",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zigcv.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .linkage = .static,
    });

    zigcv_lib.step.dependOn(&build_cmd.step);

    // Include paths
    zigcv_lib.addIncludePath(b.path("src"));
    zigcv_lib.addIncludePath(opencv_source_include);
    zigcv_lib.addIncludePath(opencv_include_dir);

    for (opencv_modules) |module| {
        zigcv_lib.addIncludePath(opencv_modules_dir.path(b, b.fmt("{s}/include", .{module})));
    }

    if (build_contrib) {
        const contrib_modules = [_][]const u8{
            "aruco",         "bgsegm",      "face",     "img_hash", "tracking",
            "wechat_qrcode", "xfeatures2d", "ximgproc", "xphoto",   "freetype",
        };
        for (contrib_modules) |module| {
            zigcv_lib.addIncludePath(opencv_contrib_modules_dir.path(b, b.fmt("{s}/include", .{module})));
        }
    }

    zigcv_lib.addLibraryPath(opencv_lib_dir);

    // Core wrapper sources (always needed)
    zigcv_lib.addCSourceFiles(.{
        .files = &.{
            "cv_error.cpp",  "calib3d.cpp",   "core.cpp",      "features2d.cpp",
            "imgcodecs.cpp", "imgproc.cpp",   "objdetect.cpp",
            "photo.cpp",     "video.cpp",     "videoio.cpp",
        },
        .root = b.path("src"),
        .flags = c_build_options,
    });

    // Optional: highgui wrapper (only if module is built)
    if (build_highgui) {
        zigcv_lib.addCSourceFile(.{
            .file = b.path("src/highgui.cpp"),
            .flags = c_build_options,
        });
    }

    // Optional: contrib wrappers (only if contrib is built)
    if (build_contrib) {
        zigcv_lib.addCSourceFiles(.{
            .files = &.{"aruco.cpp"},
            .root = b.path("src"),
            .flags = c_build_options,
        });

        zigcv_lib.addCSourceFiles(.{
            .files = &.{
                "bgsegm.cpp",   "face.cpp",          "freetype.cpp",    "img_hash.cpp",
                "tracking.cpp", "wechat_qrcode.cpp", "xfeatures2d.cpp", "ximgproc.cpp",
                "xphoto.cpp",
            },
            .root = b.path("src/contrib"),
            .flags = c_build_options,
        });
    }

    if (with_cuda) {
        // Add CUDA wrappers when they exist
        zigcv_lib.addCSourceFile(.{
            .file = b.path("src/cuda/cuda.cpp"),
            .flags = c_build_options,
        });
    }

    // Embed OpenCV static libraries
    const opencv_libs = [_][]const u8{
        "opencv_core",    "opencv_imgproc",    "opencv_imgcodecs",
        "opencv_calib3d", "opencv_features2d", "opencv_flann",
        "opencv_photo",   "opencv_video",      "opencv_videoio",
    };

    for (opencv_libs) |lib| {
        zigcv_lib.addObjectFile(opencv_lib_dir.path(b, b.fmt("lib{s}.a", .{lib})));
    }

    // Optional: highgui lib
    if (build_highgui) {
        zigcv_lib.addObjectFile(opencv_lib_dir.path(b, "libopencv_highgui.a"));
    }

    // Optional: contrib libs
    if (build_contrib) {
        const contrib_libs = [_][]const u8{
            "opencv_aruco",    "opencv_bgsegm",   "opencv_face",
            "opencv_img_hash", "opencv_tracking", "opencv_xfeatures2d",
            "opencv_ximgproc", "opencv_xphoto",
        };
        for (contrib_libs) |lib| {
            zigcv_lib.addObjectFile(opencv_lib_dir.path(b, b.fmt("lib{s}.a", .{lib})));
        }
    }

    zigcv_lib.linkLibCpp();
    zigcv_lib.linkSystemLibrary("z");

    b.installArtifact(zigcv_lib);

    // ===========================================================================
    // Tests
    // ===========================================================================

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zigcv.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    unit_tests.step.dependOn(&build_cmd.step);
    unit_tests.addIncludePath(b.path("src"));
    unit_tests.addIncludePath(opencv_source_include);
    unit_tests.addIncludePath(opencv_include_dir);

    for (opencv_modules) |module| {
        unit_tests.addIncludePath(opencv_modules_dir.path(b, b.fmt("{s}/include", .{module})));
    }

    if (build_contrib) {
        const contrib_modules = [_][]const u8{
            "aruco",         "bgsegm",      "face",     "img_hash", "tracking",
            "wechat_qrcode", "xfeatures2d", "ximgproc", "xphoto",   "freetype",
        };
        for (contrib_modules) |module| {
            unit_tests.addIncludePath(opencv_contrib_modules_dir.path(b, b.fmt("{s}/include", .{module})));
        }
    }

    unit_tests.addLibraryPath(opencv_lib_dir);
    unit_tests.addRPath(opencv_lib_dir);
    unit_tests.linkLibrary(zigcv_lib);
    unit_tests.linkLibCpp();

    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}

fn addBoolFlag(b: *std.Build, cmd: *std.Build.Step.Run, flag: []const u8, value: bool) void {
    cmd.addArgs(&.{b.fmt("-D{s}={s}", .{ flag, if (value) "ON" else "OFF" })});
}

fn addStringFlag(b: *std.Build, cmd: *std.Build.Step.Run, flag: []const u8, value: []const u8) void {
    cmd.addArgs(&.{b.fmt("-D{s}={s}", .{ flag, value })});
}
