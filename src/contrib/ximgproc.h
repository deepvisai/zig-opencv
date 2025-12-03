// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


#ifndef _OPENCV3_XIMGPROC_H_
#define _OPENCV3_XIMGPROC_H_

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <opencv2/ximgproc.hpp>
extern "C" {
#endif

#include "../core.h"

OpenCVResult anisotropicDiffusion(Mat src, Mat dst, float alpha, float K, int niters);
OpenCVResult edgePreservingFilter(Mat src, Mat dst, int d, float threshold);
OpenCVResult niBlackThreshold(Mat src, Mat dst, float maxValue, int type, int blockSize, float k, int binarizationMethod, float r);
OpenCVResult PeiLinNormalization(Mat src, Mat dst);
OpenCVResult thinning(Mat src, Mat dst, int typ);

#ifdef __cplusplus
}
#endif

#endif //_OPENCV3_XIMGPROC_H
