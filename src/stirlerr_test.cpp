#ifdef USE_OPENCL
#include "kernel_loader.h"
#define CL_TARGET_OPENCL_VERSION 300

#include <CL/cl.h>
#endif

// #include <iostream>   // removed to avoid std::cout / std::cerr
#include <vector>
#include <Rcpp.h>
#include <R.h>          // added for Rprintf

#ifdef USE_OPENCL

// 🚀 Runner for stirlerr test kernel
void stirlerr_test_runner(const std::string& source,
                          const char* kernel_name,
                          std::vector<double>& output) {
  if (output.size() != 21) {
    throw std::runtime_error("Output vector must be preallocated with size 21.");
  }
  
  cl_int status;
  // 🔍 Platform & Device
  cl_platform_id platform;
  cl_device_id device;
  status  = clGetPlatformIDs(1, &platform, nullptr);
  status |= clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, nullptr);
  
  // 🌐 Context & Queue
  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  cl_queue_properties props[] = { 0 };
  cl_command_queue queue = clCreateCommandQueueWithProperties(context, device, props, &status);
  
  // 📦 Program & Kernel
  const char* src_ptr = source.c_str();
  size_t src_len     = source.size();
  cl_program program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
  status |= clBuildProgram(program, 0, nullptr, nullptr, nullptr, nullptr);
  cl_kernel kernel = clCreateKernel(program, kernel_name, &status);
  
  // 🧮 Device Buffers
  cl_mem output_buf = clCreateBuffer(
    context,
    CL_MEM_WRITE_ONLY,
    sizeof(double) * output.size(),
    nullptr,
    &status
  );
  clSetKernelArg(kernel, 0, sizeof(cl_mem), &output_buf);
  
  // 🚀 Launch Kernel (Single Work-Item)
  size_t global_size = 1;
  clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global_size, nullptr, 0, nullptr, nullptr);
  
  // 📥 Retrieve Output
  clEnqueueReadBuffer(
    queue,
    output_buf,
    CL_TRUE,
    0,
    sizeof(double) * output.size(),
    output.data(),
    0,
    nullptr,
    nullptr
  );
  
  // 🧹 Cleanup
  clReleaseMemObject(output_buf);
  clReleaseKernel(kernel);
  clReleaseProgram(program);
  clReleaseCommandQueue(queue);
  clReleaseContext(context);
}

#endif

// [[Rcpp::export]]
Rcpp::NumericVector stirlerr_test_wrapper() {
  const size_t stride = 21;
  std::vector<double> output(stride);
  
#ifdef USE_OPENCL
  std::string dpq_source        = load_kernel_library("dpq");
  std::string rmath_source      = load_kernel_library("rmath");
  std::string nmath_source      = load_kernel_library("nmath");
  std::string test_kernel_code  = load_kernel_source("test/stirlerr_test_kernel.cl");
  
  // std::string kernel_code = dpq_source + rmath_source + nmath_source + test_kernel_code;
  std::string kernel_code = dpq_source + rmath_source + nmath_source + test_kernel_code;
  
  Rprintf("%s\n", kernel_code.c_str());   // replaced std::cout
  
  stirlerr_test_runner(kernel_code, "stirlerr_test_kernel", output);
  
#else  
  Rcpp::Rcout << "[INFO] OpenCL not available — returning zero vector.\n";
#endif  
  
  return Rcpp::NumericVector(output.begin(), output.end());
}
