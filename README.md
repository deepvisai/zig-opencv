# Zig OpenCV

![Zig OpenCV Mascot](mascot.png)

**Explicit Zig bindings for OpenCV with full build-time control**

A comprehensive OpenCV wrapper for Zig that compiles OpenCV from source and provides idiomatic Zig bindings. Unlike other bindings, this project gives you complete control over OpenCV's build configuration directly from your `build.zig`.

## Features

- 🎯 **Explicit control** - Configure OpenCV modules, SIMD, GPU support, and more from Zig
- 📦 **Static linking** - Embeds OpenCV directly into your binary
- 🚀 **Zero runtime dependencies** - Self-contained executables
- 🔧 **Cross-compilation ready** - Works with Zig's cross-compilation toolchain
- ⚡ **Optimized builds** - SIMD intrinsics, fast math, and LTO support

## Installation

Add zig-opencv to your project:
```bash
zig fetch --save git+https://github.com/madsludvig/zig-opencv.git
```

## Usage

In your `build.zig`:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add zig-opencv dependency
    const zigcv = b.dependency("zig-opencv", .{
        .target = target,
        .optimize = optimize,
        
        // Optional: Configure OpenCV build
        .enable_intrinsics = true,
        .cpu_baseline = "SSE4_2",
        .with_jpeg = true,
        .with_png = true,
        .build_contrib = true,
    });

    const exe = b.addExecutable(.{
        .name = "my_app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Import and link
    exe.root_module.addImport("zigcv", zigcv.module("zigcv"));
    exe.linkLibrary(zigcv.artifact("zigcv"));

    b.installArtifact(exe);
}
```

In your `src/main.zig`:
```zig
const std = @import("std");
const cv = @import("zigcv");

pub fn main() !void {
    // Your OpenCV code here
    std.debug.print("OpenCV version: {s}\n", .{cv.version()});
}
```

## Build Options

Configure OpenCV at build time:
```bash
# Enable CUDA support
zig build -Dwith_cuda=true

# Optimize for specific CPU
zig build -Dcpu_baseline=AVX2

# Disable contrib modules for faster builds
zig build -Dbuild_contrib=false
```

See `zig build --help` for all available options.

## Requirements

- Zig 0.16.0 or later
- CMake 3.10 or later
- C++ compiler (zig cc is used by default)

## License

MIT

## Acknowledgments

This project was inspired by and built upon the work of:
- [GoCV](https://github.com/hybridgroup/gocv) - Go bindings for OpenCV, whose C wrapper layer served as a foundation
- [zigcv](https://github.com/ryoppippi/zigcv) - Another Zig OpenCV project that provided valuable insights

Special thanks to these projects for paving the way for OpenCV bindings in modern languages.
