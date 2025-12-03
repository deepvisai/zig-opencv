// Originally from GoCV (https://github.com/hybridgroup/gocv)
// Copyright (c) 2017-2024 The Hybrid Group
// Licensed under Apache License 2.0
//
// Modified for zig-opencv, 2025
// Modifications licensed under MIT License


//go:build !gocv_specific_modules || (gocv_specific_modules && gocv_svd)

#include "svd.h"

OpenCVResult SVD_Compute(Mat src, Mat w, Mat u, Mat vt) {
    try {
        cv::SVD::compute(*src, *w, *u, *vt, 0);
        return successResult();
    } catch(const cv::Exception& e) {
        return errorResult(e.code, e.what());
    }
}