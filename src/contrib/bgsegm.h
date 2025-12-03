// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


#ifndef _OPENCV3_BGSEGM_H_
#define _OPENCV3_BGSEGM_H_

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <opencv2/bgsegm.hpp>
extern "C" {
#endif

#include "../core.h"

#ifdef __cplusplus
typedef cv::Ptr<cv::bgsegm::BackgroundSubtractorCNT>* BackgroundSubtractorCNT;
#else
typedef void* BackgroundSubtractorCNT;
#endif

BackgroundSubtractorCNT BackgroundSubtractorCNT_Create();
void BackgroundSubtractorCNT_Close(BackgroundSubtractorCNT b);
OpenCVResult BackgroundSubtractorCNT_Apply(BackgroundSubtractorCNT b, Mat src, Mat dst);

#ifdef __cplusplus
}
#endif

#endif //_OPENCV3_BGSEGM_H_
