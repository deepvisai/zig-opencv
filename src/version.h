// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


#ifndef _OPENCV3_VERSION_H_
#define _OPENCV3_VERSION_H_

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
extern "C" {
#endif

#include "core.h"

const char* openCVVersion();

#ifdef __cplusplus
}
#endif

#endif //_OPENCV3_VERSION_H_
