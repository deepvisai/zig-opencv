// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


#include "../core.h"
#include "core.h"
#include <string.h>

void GpuRects_Close(struct Rects rs) {
    delete[] rs.rects;
}
