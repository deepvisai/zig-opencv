// Zig-OpenCV Error Handling Implementation
// Copyright 2025
// Licensed under MIT License

#include "cv_error.h"
#include <opencv2/core.hpp>
#include <string.h>

// Thread-local storage for last error message
// Stores detailed exception message from cv::Exception::what()
static thread_local char last_error_message[2048] = {0};

CVError cv_error_from_opencv_code(int opencv_code) {
    // Map OpenCV cv::Error::Code values to CVError enum
    switch(opencv_code) {
        case cv::Error::StsOk:
            return CV_OK;
        case cv::Error::StsBackTrace:
        case cv::Error::StsError:
            return CV_ERR_STS_ERROR;
        case cv::Error::StsInternal:
            return CV_ERR_STS_INTERNAL_ERROR;
        case cv::Error::StsNoMem:
            return CV_ERR_STS_NO_MEM;
        case cv::Error::StsBadArg:
            return CV_ERR_STS_BAD_ARG;
        case cv::Error::StsBadFunc:
            return CV_ERR_STS_BAD_FUNC;
        case cv::Error::StsNoConv:
            return CV_ERR_STS_NO_CONV;
        case cv::Error::StsAutoTrace:
            return CV_ERR_STS_AUTO_TRACE;
        case cv::Error::HeaderIsNull:
            return CV_ERR_STS_HEADER_IS_NULL;
        case cv::Error::BadImageSize:
        case cv::Error::StsBadSize:
            return CV_ERR_STS_BAD_SIZE;
        case cv::Error::BadDepth:
            return CV_ERR_STS_BAD_DEPTH;
        case cv::Error::BadNumChannels:
        case cv::Error::BadNumChannel1U:
            return CV_ERR_STS_BAD_CHANNELS;
        case cv::Error::BadCOI:
        case cv::Error::BadOrder:
        case cv::Error::BadStep:
            return CV_ERR_STS_BAD_TYPE;
        case cv::Error::BadDataPtr:
        case cv::Error::BadAlphaChannel:
        case cv::Error::BadOffset:
            return CV_ERR_STS_BAD_OFFSET;
        case cv::Error::StsOutOfRange:
        case cv::Error::BadROISize:
            return CV_ERR_STS_BAD_RANGE;
        case cv::Error::StsNullPtr:
            return CV_ERR_STS_NULL_PTR;
        case cv::Error::StsAssert:
        case cv::Error::StsVecLengthErr:
        case cv::Error::StsFilterStructContentErr:
        case cv::Error::StsKernelStructContentErr:
        case cv::Error::StsFilterOffsetErr:
        case cv::Error::StsBadFlag:
        case cv::Error::StsDivByZero:
        case cv::Error::StsUnsupportedFormat:
        case cv::Error::StsObjectNotFound:
        case cv::Error::BadTileSize:
        case cv::Error::StsUnmatchedFormats:
        case cv::Error::StsUnmatchedSizes:
            return CV_ERR_STS_ASSERT;
        case cv::Error::GpuNotSupported:
            return CV_ERR_GPU_NOT_SUPPORTED;
        case cv::Error::GpuApiCallError:
            return CV_ERR_GPU_API_CALL_ERROR;
        case cv::Error::OpenGlNotSupported:
        case cv::Error::OpenGlApiCallError:
        case cv::Error::OpenCLApiCallError:
        case cv::Error::OpenCLDoubleNotSupported:
        case cv::Error::OpenCLInitError:
        case cv::Error::OpenCLNoAMDBlasFft:
            return CV_ERR_GPU_API_CALL_ERROR;
        default:
            // Unknown or unmapped error code
            return CV_ERR_UNKNOWN;
    }
}

const char* cv_error_string(CVError err) {
    // Return human-readable error message for each error code
    switch(err) {
        case CV_OK:
            return "Success";
        case CV_ERR_UNKNOWN:
            return "Unknown error";
        case CV_ERR_STS_ERROR:
            return "Generic OpenCV error";
        case CV_ERR_STS_INTERNAL_ERROR:
            return "Internal OpenCV error (bad state)";
        case CV_ERR_STS_NO_MEM:
            return "Insufficient memory";
        case CV_ERR_STS_BAD_ARG:
            return "Bad argument (incorrect range, value, or null pointer)";
        case CV_ERR_STS_BAD_FUNC:
            return "Function not implemented";
        case CV_ERR_STS_NO_CONV:
            return "Iteration did not converge";
        case CV_ERR_STS_AUTO_TRACE:
            return "Tracing";
        case CV_ERR_STS_HEADER_IS_NULL:
            return "Image header is NULL";
        case CV_ERR_STS_BAD_SIZE:
            return "Incorrect size of input array";
        case CV_ERR_STS_BAD_DEPTH:
            return "Input array depth is not supported by this function";
        case CV_ERR_STS_BAD_CHANNELS:
            return "Number of channels is not supported";
        case CV_ERR_STS_BAD_TYPE:
            return "Bad data type or unsupported combination of types";
        case CV_ERR_STS_BAD_OFFSET:
            return "Offset is invalid";
        case CV_ERR_STS_BAD_RANGE:
            return "Bad range of values";
        case CV_ERR_STS_NULL_PTR:
            return "Null pointer provided";
        case CV_ERR_STS_ASSERT:
            return "Assertion failed";
        case CV_ERR_GPU_NOT_SUPPORTED:
            return "GPU/CUDA operation not supported";
        case CV_ERR_GPU_API_CALL_ERROR:
            return "GPU API call failed";
        case CV_ERR_GPU_NVCUVID_ERROR:
            return "NVCUVID API call failed";
        case CV_ERR_FILE_NOT_FOUND:
            return "File not found";
        case CV_ERR_FILE_READ:
            return "File read error";
        case CV_ERR_FILE_WRITE:
            return "File write error";
        default:
            return "Unknown error code";
    }
}

const char* cv_get_last_error_message(void) {
    return last_error_message;
}

void cv_clear_last_error_message(void) {
    last_error_message[0] = '\0';
}

void cv_set_last_error_message(const char* msg) {
    if (msg == nullptr) {
        cv_clear_last_error_message();
        return;
    }

    // Copy message with bounds checking
    strncpy(last_error_message, msg, sizeof(last_error_message) - 1);
    last_error_message[sizeof(last_error_message) - 1] = '\0';
}
