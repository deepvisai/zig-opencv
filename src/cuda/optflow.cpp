// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


//go:build !gocv_specific_modules || (gocv_specific_modules && gocv_cuda_optflow)

#include "optflow.h"

CudaSparsePyrLKOpticalFlow CudaSparsePyrLKOpticalFlow_Create() {
    try {
        return new cv::Ptr<cv::cuda::SparsePyrLKOpticalFlow>(cv::cuda::SparsePyrLKOpticalFlow::create());
    } catch(const cv::Exception& e){
        setExceptionInfo(e.code, e.what());
        return NULL;
    }
}

OpenCVResult CudaSparsePyrLKOpticalFlow_Calc(CudaSparsePyrLKOpticalFlow p, GpuMat prevImg, GpuMat nextImg, GpuMat prevPts, GpuMat nextPts, GpuMat status){
    try {
        (*p)->calc(*prevImg,*nextImg,*prevPts,*nextPts,*status);
        return successResult();
    } catch(const cv::Exception& e) {
        return errorResult(e.code, e.what());
    }
}