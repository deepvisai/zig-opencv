// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


#ifndef _OPENCV_CUDAOPTFLOW_HPP_
#define _OPENCV_CUDAOPTFLOW_HPP_

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/cudaoptflow.hpp>

extern "C" {
#endif

#include "../core.h"
#include "cuda.h"

#ifdef __cplusplus
typedef cv::Ptr<cv::cuda::SparsePyrLKOpticalFlow>* CudaSparsePyrLKOpticalFlow;
#else
typedef void* CudaSparsePyrLKOpticalFlow;
#endif

CudaSparsePyrLKOpticalFlow CudaSparsePyrLKOpticalFlow_Create();
OpenCVResult CudaSparsePyrLKOpticalFlow_Calc(CudaSparsePyrLKOpticalFlow p, GpuMat prevImg, GpuMat nextImg, GpuMat prevPts, GpuMat nextPts, GpuMat status);

#ifdef __cplusplus
}
#endif

#endif // _OPENCV_CUDAOPTFLOW_HPP_