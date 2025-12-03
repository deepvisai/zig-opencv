// Zig-OpenCV Error Handling
// Copyright 2025
// Licensed under MIT License

#ifndef _CV_ERROR_H_
#define _CV_ERROR_H_

#ifdef __cplusplus
extern "C" {
#endif

// Error codes based on OpenCV cv::Error::Code enum
// Values match OpenCV's internal error codes for compatibility
typedef enum {
    CV_OK = 0,                          // Success

    // OpenCV standard error codes (from opencv2/core/base.hpp)
    CV_ERR_STS_ERROR = -1,              // Generic error
    CV_ERR_UNKNOWN = -999,              // Unknown/unspecified error
    CV_ERR_STS_INTERNAL_ERROR = -2,     // Internal error (bad state)
    CV_ERR_STS_NO_MEM = -3,             // Insufficient memory
    CV_ERR_STS_BAD_ARG = -5,            // Bad argument (incorrect range, null pointer, etc)
    CV_ERR_STS_BAD_FUNC = -6,           // Function not implemented
    CV_ERR_STS_NO_CONV = -7,            // Iteration did not converge
    CV_ERR_STS_AUTO_TRACE = -8,         // Tracing
    CV_ERR_STS_HEADER_IS_NULL = -9,     // Image header is NULL
    CV_ERR_STS_BAD_SIZE = -201,         // Incorrect size of input array
    CV_ERR_STS_BAD_DEPTH = -202,        // Input array depth is not supported
    CV_ERR_STS_BAD_CHANNELS = -203,     // Number of channels is unexpected
    CV_ERR_STS_BAD_TYPE = -204,         // Bad data type (from cv::Mat type)
    CV_ERR_STS_BAD_OFFSET = -205,       // Offset is invalid
    CV_ERR_STS_BAD_RANGE = -211,        // Bad range of values
    CV_ERR_STS_NULL_PTR = -27,          // Null pointer
    CV_ERR_STS_ASSERT = -215,           // Assertion failed
    CV_ERR_GPU_NOT_SUPPORTED = -217,    // GPU operation not supported
    CV_ERR_GPU_API_CALL_ERROR = -218,   // GPU API call failed
    CV_ERR_GPU_NVCUVID_ERROR = -219,    // NVCUVID API call failed

    // Additional file/IO errors
    CV_ERR_FILE_NOT_FOUND = -301,       // File not found
    CV_ERR_FILE_READ = -302,            // File read error
    CV_ERR_FILE_WRITE = -303,           // File write error
} CVError;

// Convert OpenCV exception code to CVError
// Maps cv::Exception::code to corresponding CVError value
CVError cv_error_from_opencv_code(int opencv_code);

// Get human-readable error message from error code
// Returns a static string describing the error
const char* cv_error_string(CVError err);

// Get the last error message from an exception
// Returns detailed error message from last cv::Exception caught
// Returns empty string if no error or after cv_clear_last_error_message()
const char* cv_get_last_error_message(void);

// Clear the last error message
// Call after reading/logging an error message
void cv_clear_last_error_message(void);

// Set the last error message (internal use)
// Called internally when catching cv::Exception
void cv_set_last_error_message(const char* msg);

#ifdef __cplusplus
}
#endif

#endif // _CV_ERROR_H_
