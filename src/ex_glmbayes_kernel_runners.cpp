
#ifdef USE_OPENCL

#ifdef USE_DIRECT_CLH
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#else
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#endif
#endif


//#include <Rcpp.h>
#include <RcppArmadillo.h>
#include "openclPort.h"
#include "opencl.h"
#include <vector>
#include <string>

using namespace openclPort;
using namespace glmbayes::opencl;

#ifdef USE_OPENCL

namespace glmbayes {

namespace opencl {

void f2_f3_kernel_runner(
    const std::string&        kernel_source,
    const char*               kernel_name,
    int                       l1,
    int                       l2,
    int                       m1,
    const std::vector<double>& X_flat,
    const std::vector<double>& B_flat,
    const std::vector<double>& mu_flat,
    const std::vector<double>& P_flat,
    const std::vector<double>& alpha_flat,
    const std::vector<double>& y_flat,
    const std::vector<double>& wt_flat,
    std::vector<double>&       qf_flat,
    std::vector<double>&       grad_flat,
    int                        progbar
) {
  // 0) Sanity-check sizes
  if ((int)X_flat.size()    != l1*l2 ||
      (int)B_flat.size()    != m1*l2 ||
      (int)mu_flat.size()   != l2    ||
      (int)P_flat.size()    != l2*l2 ||
      (int)alpha_flat.size()!= l1    ||
      (int)y_flat.size()    != l1    ||
      (int)wt_flat.size()   != l1) {
    throw std::runtime_error("Input flat-vector sizes mismatch dimensions.");
  }

  // 1) Initialize output buffers
  qf_flat.assign(m1, 0.0);
  grad_flat.assign((size_t)l2*m1, 0.0);

  cl_int status = 0;
  std::string build_log;
  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step
          << " (status=" << s
          << ", name=" << opencl_status_name(s) << "). "
          << opencl_status_hint(s);
      throw std::runtime_error(msg.str());
    }
  };

  // 2) Platform & Device
  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  status = clGetPlatformIDs(1, &platform, nullptr);
  if (status == -1001) {
    throw std::runtime_error(
        "OpenCL error: no OpenCL platforms found (clGetPlatformIDs returned -1001). "
        "Your system does not expose an OpenCL platform."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetPlatformIDs failed with status " << status
        << " (" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
    throw std::runtime_error(msg.str());
  }

  status = clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, nullptr);
  if (status == -9) {
    throw std::runtime_error(
        "OpenCL error: no suitable OpenCL GPU devices found "
        "(clGetDeviceIDs returned -9)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetDeviceIDs failed with status " << status
        << " (" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
    throw std::runtime_error(msg.str());
  }

  // 3) Context & Queue
  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  if (status != CL_SUCCESS) {
    throw opencl_make_context_error(status, platform, device);
  }

  cl_queue_properties props[] = {0};
  cl_command_queue queue = clCreateCommandQueueWithProperties(context, device, props, &status);
  require_success(status, "clCreateCommandQueueWithProperties");

  // 4) Program & Kernel
  const char* src_ptr = kernel_source.c_str();
  size_t      src_len = kernel_source.size();
  cl_program  program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
  require_success(status, "clCreateProgramWithSource");

  auto read_build_log = [&](cl_program prog) {
    size_t log_size = 0;
    cl_int s0 = clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, 0, nullptr, &log_size);
    if (s0 != CL_SUCCESS || log_size == 0) return std::string();
    std::string log(log_size, '\0');
    cl_int s1 = clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, log_size, &log[0], nullptr);
    if (s1 != CL_SUCCESS) return std::string();
    return log;
  };

  status = clBuildProgram(program, 0, nullptr, nullptr, nullptr, nullptr);
  build_log = read_build_log(program);
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error at clBuildProgram (status=" << status
        << ", name=" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
    if (!build_log.empty()) {
      msg << "\nBuild log:\n" << build_log;
    }
    throw std::runtime_error(msg.str());
  }
  if (progbar > 0 && !build_log.empty()) {
    Rcpp::Rcout << "[OpenCL build log]\n" << build_log << "\n";
  }

  cl_kernel kernel = clCreateKernel(program, kernel_name, &status);
  require_success(status, "clCreateKernel");

  // 5) Device Buffers
  cl_mem bufX    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*X_flat.size(),   (void*)X_flat.data(),   &status);
  require_success(status, "clCreateBuffer(bufX)");
  cl_mem bufB    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*B_flat.size(),   (void*)B_flat.data(),   &status);
  require_success(status, "clCreateBuffer(bufB)");
  cl_mem bufMu   = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*mu_flat.size(),  (void*)mu_flat.data(),  &status);
  require_success(status, "clCreateBuffer(bufMu)");
  cl_mem bufP    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*P_flat.size(),   (void*)P_flat.data(),   &status);
  require_success(status, "clCreateBuffer(bufP)");
  cl_mem bufA    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*alpha_flat.size(), (void*)alpha_flat.data(), &status);
  require_success(status, "clCreateBuffer(bufA)");
  cl_mem bufY    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*y_flat.size(),   (void*)y_flat.data(),   &status);
  require_success(status, "clCreateBuffer(bufY)");
  cl_mem bufW    = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR,
                                  sizeof(double)*wt_flat.size(),  (void*)wt_flat.data(),  &status);
  require_success(status, "clCreateBuffer(bufW)");

  cl_mem bufQF   = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                                  sizeof(double)*qf_flat.size(),   nullptr, &status);
  require_success(status, "clCreateBuffer(bufQF)");
  cl_mem bufGrad = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                                  sizeof(double)*grad_flat.size(), nullptr, &status);
  require_success(status, "clCreateBuffer(bufGrad)");

  // 6) Set Kernel Args
  int arg = 0;
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufX);
  require_success(status, "clSetKernelArg(bufX)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufB);
  require_success(status, "clSetKernelArg(bufB)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufMu);
  require_success(status, "clSetKernelArg(bufMu)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufP);
  require_success(status, "clSetKernelArg(bufP)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufA);
  require_success(status, "clSetKernelArg(bufA)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufY);
  require_success(status, "clSetKernelArg(bufY)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufW);
  require_success(status, "clSetKernelArg(bufW)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufQF);
  require_success(status, "clSetKernelArg(bufQF)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufGrad);
  require_success(status, "clSetKernelArg(bufGrad)");
  status = clSetKernelArg(kernel, arg++, sizeof(int),    &l1);
  require_success(status, "clSetKernelArg(l1)");
  status = clSetKernelArg(kernel, arg++, sizeof(int),    &l2);
  require_success(status, "clSetKernelArg(l2)");
  status = clSetKernelArg(kernel, arg++, sizeof(int),    &m1);
  require_success(status, "clSetKernelArg(m1)");

  // 7) Launch
  size_t global = (size_t)m1;
  status = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
  require_success(status, "clEnqueueNDRangeKernel");

  // 8) Read back outputs
  status = clEnqueueReadBuffer(queue, bufQF,   CL_TRUE, 0,
                               sizeof(double)*qf_flat.size(),   qf_flat.data(),
                               0, nullptr, nullptr);
  require_success(status, "clEnqueueReadBuffer(qf)");

  status = clEnqueueReadBuffer(queue, bufGrad, CL_TRUE, 0,
                               sizeof(double)*grad_flat.size(), grad_flat.data(),
                               0, nullptr, nullptr);
  require_success(status, "clEnqueueReadBuffer(grad)");

  // 8a) Sanity-check: error out if both outputs are all zeros
  {
    auto all_zero = [](auto& vec){
      return std::all_of(vec.begin(), vec.end(),
                         [](double x){ return x == 0.0; });
    };

    bool qf_is_zero   = (!qf_flat.empty()) && all_zero(qf_flat);
    bool grad_is_zero = (!grad_flat.empty()) && all_zero(grad_flat);

    if (qf_is_zero || grad_is_zero) {
      std::ostringstream msg;
      msg << "OpenCL kernel returned "
          << (qf_is_zero   ? "qf_flat all zeros "   : "")
          << (grad_is_zero ? "grad_flat all zeros." : "")
          << " [kernel=" << kernel_name
          << ", l1=" << l1 << ", l2=" << l2 << ", m1=" << m1 << ", global=" << global << "]";
      if (!build_log.empty()) {
        msg << "\nBuild log:\n" << build_log;
      }
      throw std::runtime_error(msg.str());
    }
  }

  clFlush(queue);
  clFinish(queue);

  clReleaseMemObject(bufGrad);
  clReleaseMemObject(bufQF);
  clReleaseMemObject(bufW);
  clReleaseMemObject(bufY);
  clReleaseMemObject(bufA);
  clReleaseMemObject(bufP);
  clReleaseMemObject(bufMu);
  clReleaseMemObject(bufB);
  clReleaseMemObject(bufX);

  clReleaseKernel       (kernel);
  clReleaseProgram      (program);
  clReleaseCommandQueue (queue);
  clReleaseContext      (context);
}

}
}

#endif
