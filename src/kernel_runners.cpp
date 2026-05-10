

#ifdef USE_OPENCL

#ifdef USE_DIRECT_CLH
#define CL_TARGET_OPENCL_VERSION 300

// we passed “-I…/include/CL -DUSE_DIRECT_CLH”
#include <CL/cl.h>
#else
#define CL_TARGET_OPENCL_VERSION 300

// normal case on Linux/macOS/Windows
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

namespace {

const char* opencl_status_name(cl_int status) {
  switch (status) {
    case CL_SUCCESS: return "CL_SUCCESS";
    case CL_DEVICE_NOT_FOUND: return "CL_DEVICE_NOT_FOUND";
    case CL_DEVICE_NOT_AVAILABLE: return "CL_DEVICE_NOT_AVAILABLE";
    case CL_COMPILER_NOT_AVAILABLE: return "CL_COMPILER_NOT_AVAILABLE";
    case CL_MEM_OBJECT_ALLOCATION_FAILURE: return "CL_MEM_OBJECT_ALLOCATION_FAILURE";
    case CL_OUT_OF_RESOURCES: return "CL_OUT_OF_RESOURCES";
    case CL_OUT_OF_HOST_MEMORY: return "CL_OUT_OF_HOST_MEMORY";
    case CL_BUILD_PROGRAM_FAILURE: return "CL_BUILD_PROGRAM_FAILURE";
    case CL_INVALID_VALUE: return "CL_INVALID_VALUE";
    case CL_INVALID_DEVICE: return "CL_INVALID_DEVICE";
    case CL_INVALID_BINARY: return "CL_INVALID_BINARY";
    case CL_INVALID_BUILD_OPTIONS: return "CL_INVALID_BUILD_OPTIONS";
    case CL_INVALID_PROGRAM: return "CL_INVALID_PROGRAM";
    case CL_INVALID_OPERATION: return "CL_INVALID_OPERATION";
    case CL_INVALID_PLATFORM: return "CL_INVALID_PLATFORM";
    case CL_INVALID_CONTEXT: return "CL_INVALID_CONTEXT";
    default: return "UNKNOWN_OR_VENDOR_SPECIFIC";
  }
}

std::string read_platform_info_str(cl_platform_id platform, cl_platform_info param) {
  if (platform == nullptr) return "unknown";
  size_t n = 0;
  if (clGetPlatformInfo(platform, param, 0, nullptr, &n) != CL_SUCCESS || n == 0) {
    return "unknown";
  }
  std::string out(n, '\0');
  if (clGetPlatformInfo(platform, param, n, &out[0], nullptr) != CL_SUCCESS) {
    return "unknown";
  }
  if (!out.empty() && out.back() == '\0') out.pop_back();
  return out.empty() ? "unknown" : out;
}

std::string read_device_info_str(cl_device_id device, cl_device_info param) {
  if (device == nullptr) return "unknown";
  size_t n = 0;
  if (clGetDeviceInfo(device, param, 0, nullptr, &n) != CL_SUCCESS || n == 0) {
    return "unknown";
  }
  std::string out(n, '\0');
  if (clGetDeviceInfo(device, param, n, &out[0], nullptr) != CL_SUCCESS) {
    return "unknown";
  }
  if (!out.empty() && out.back() == '\0') out.pop_back();
  return out.empty() ? "unknown" : out;
}

std::runtime_error make_context_error(cl_int status, cl_platform_id platform, cl_device_id device) {
  std::ostringstream msg;
  msg << "OpenCL error at clCreateContext (status=" << status
      << ", name=" << opencl_status_name(status) << "). "
      << "platform_name=" << read_platform_info_str(platform, CL_PLATFORM_NAME)
      << ", platform_vendor=" << read_platform_info_str(platform, CL_PLATFORM_VENDOR)
      << ", device_name=" << read_device_info_str(device, CL_DEVICE_NAME)
      << ", driver_version=" << read_device_info_str(device, CL_DRIVER_VERSION)
      << ". This may indicate a transient driver/runtime context failure.";
  return std::runtime_error(msg.str());
}

} // namespace

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
      msg << "OpenCL error at " << step << " (status=" << s << ").";
      throw std::runtime_error(msg.str());
    }
  };
  
  // 2) Platform & Device
  // Rcpp::Rcout << "[runner] P0: before clGetPlatformIDs\n";
  
  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;
  
  // ---- Platform ----
  status = clGetPlatformIDs(1, &platform, nullptr);

  // -1001 = CL_PLATFORM_NOT_FOUND_KHR (not always defined in headers)
  if (status == -1001) {
    throw std::runtime_error(
        "OpenCL error: no OpenCL platforms found (clGetPlatformIDs returned -1001). "
        "Your system does not expose an OpenCL platform."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetPlatformIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }
  
  // ---- Device ----
  status = clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, nullptr);

  // -9 = CL_DEVICE_NOT_FOUND
  if (status == -9) {
    throw std::runtime_error(
        "OpenCL error: no suitable OpenCL GPU devices found "
        "(clGetDeviceIDs returned -9)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetDeviceIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }
  
  // 3) Context & Queue
  // Rcpp::Rcout << "[runner] P3: before clCreateContext\n";
  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  if (status != CL_SUCCESS) {
    throw make_context_error(status, platform, device);
  }
  // Rcpp::Rcout << "[runner] P4: after clCreateContext, status=" << status << "\n";
  
  cl_queue_properties props[] = {0};
  // Rcpp::Rcout << "[runner] P5: before clCreateCommandQueueWithProperties\n";
  cl_command_queue queue = clCreateCommandQueueWithProperties(context, device, props, &status);
  require_success(status, "clCreateCommandQueueWithProperties");
  // Rcpp::Rcout << "[runner] P6: after clCreateCommandQueueWithProperties, status=" << status << "\n";
  
  // 4) Program & Kernel
  const char* src_ptr = kernel_source.c_str();
  size_t      src_len = kernel_source.size();
  // Rcpp::Rcout << "[runner] P7: before clCreateProgramWithSource, src_len=" << src_len << "\n";
  cl_program  program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
  require_success(status, "clCreateProgramWithSource");
  // Rcpp::Rcout << "[runner] P8: after clCreateProgramWithSource, status=" << status << "\n";
  auto read_build_log = [&](cl_program prog) {
    size_t log_size = 0;
    cl_int s0 = clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, 0, nullptr, &log_size);
    if (s0 != CL_SUCCESS || log_size == 0) return std::string();
    std::string log(log_size, '\0');
    cl_int s1 = clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, log_size, &log[0], nullptr);
    if (s1 != CL_SUCCESS) return std::string();
    return log;
  };
  
  // Rcpp::Rcout << "[runner] P9: before clBuildProgram\n";
  status = clBuildProgram(program, 0, nullptr, nullptr, nullptr, nullptr);
  build_log = read_build_log(program);
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error at clBuildProgram (status=" << status << ").";
    if (!build_log.empty()) {
      msg << "\nBuild log:\n" << build_log;
    }
    throw std::runtime_error(msg.str());
  }
  if (progbar > 0 && !build_log.empty()) {
    Rcpp::Rcout << "[OpenCL build log]\n" << build_log << "\n";
  }
  // Rcpp::Rcout << "[runner] P10: after clBuildProgram, status=" << status << "\n";
  
  // Rcpp::Rcout << "[runner] P11: before clCreateKernel\n";
  cl_kernel kernel = clCreateKernel(program, kernel_name, &status);
  require_success(status, "clCreateKernel");
  // Rcpp::Rcout << "[runner] P12: after clCreateKernel, status=" << status << "\n";
  
  // 5) Device Buffers
  // Rcpp::Rcout << "[runner] A: before buffer creation\n";
  
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
  
  // Rcpp::Rcout << "[runner] B: after buffer creation\n";
  
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
  // Rcpp::Rcout << "[runner] C: before enqueue\n";
  status = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
  require_success(status, "clEnqueueNDRangeKernel");
  // Rcpp::Rcout << "[runner] D: after enqueue\n";
  
  // 8) Read back outputs
  // Rcpp::Rcout << "[runner] E: before read qf\n";
  status = clEnqueueReadBuffer(queue, bufQF,   CL_TRUE, 0,
                               sizeof(double)*qf_flat.size(),   qf_flat.data(),
                               0, nullptr, nullptr);
  require_success(status, "clEnqueueReadBuffer(qf)");
  // Rcpp::Rcout << "[runner] F: after read qf\n";
  
  // Rcpp::Rcout << "[runner] G: before read grad\n";
  status = clEnqueueReadBuffer(queue, bufGrad, CL_TRUE, 0,
                               sizeof(double)*grad_flat.size(), grad_flat.data(),
                               0, nullptr, nullptr);
  require_success(status, "clEnqueueReadBuffer(grad)");
  // Rcpp::Rcout << "[runner] H: after read grad\n";
  
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

void dnorm_kernel_runner(
    const std::string&         kernel_source,
    const char*                kernel_name,
    const std::vector<double>& x_flat,
    double                     mu,
    double                     sigma,
    int                        give_log,
    std::vector<double>&       out_flat
) {
  const int n = static_cast<int>(x_flat.size());
  out_flat.assign(static_cast<size_t>(n), 0.0);

  cl_int status = 0;
  std::string build_log;

  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step << " (status=" << s << ").";
      throw std::runtime_error(msg.str());
    }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  status = clGetPlatformIDs(1, &platform, nullptr);
  if (status == -1001) {
    throw std::runtime_error(
      "OpenCL error: no OpenCL platforms found (clGetPlatformIDs returned -1001)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetPlatformIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }

  status = clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, nullptr);
  if (status == -9) {
    throw std::runtime_error(
      "OpenCL error: no suitable OpenCL devices found (clGetDeviceIDs returned -9)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetDeviceIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }

  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  if (status != CL_SUCCESS) {
    throw make_context_error(status, platform, device);
  }

  cl_queue_properties props[] = {0};
  cl_command_queue queue = clCreateCommandQueueWithProperties(context, device, props, &status);
  require_success(status, "clCreateCommandQueueWithProperties");

  const char* src_ptr = kernel_source.c_str();
  size_t src_len = kernel_source.size();
  cl_program program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
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
    msg << "OpenCL error at clBuildProgram (status=" << status << ").";
    if (!build_log.empty()) msg << "\nBuild log:\n" << build_log;
    throw std::runtime_error(msg.str());
  }

  cl_kernel kernel = clCreateKernel(program, kernel_name, &status);
  require_success(status, "clCreateKernel");

  cl_mem bufX = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      sizeof(double) * x_flat.size(), (void*)x_flat.data(), &status
  );
  require_success(status, "clCreateBuffer(bufX)");

  cl_mem bufOut = clCreateBuffer(
      context, CL_MEM_WRITE_ONLY,
      sizeof(double) * out_flat.size(), nullptr, &status
  );
  require_success(status, "clCreateBuffer(bufOut)");

  int arg = 0;
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufX);
  require_success(status, "clSetKernelArg(bufX)");
  status = clSetKernelArg(kernel, arg++, sizeof(double), &mu);
  require_success(status, "clSetKernelArg(mu)");
  status = clSetKernelArg(kernel, arg++, sizeof(double), &sigma);
  require_success(status, "clSetKernelArg(sigma)");
  status = clSetKernelArg(kernel, arg++, sizeof(int), &give_log);
  require_success(status, "clSetKernelArg(give_log)");
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufOut);
  require_success(status, "clSetKernelArg(bufOut)");
  status = clSetKernelArg(kernel, arg++, sizeof(int), &n);
  require_success(status, "clSetKernelArg(n)");

  size_t global = static_cast<size_t>(n);
  status = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
  require_success(status, "clEnqueueNDRangeKernel");

  status = clEnqueueReadBuffer(
      queue, bufOut, CL_TRUE, 0,
      sizeof(double) * out_flat.size(), out_flat.data(),
      0, nullptr, nullptr
  );
  require_success(status, "clEnqueueReadBuffer(out)");

  clFlush(queue);
  clFinish(queue);

  clReleaseMemObject(bufOut);
  clReleaseMemObject(bufX);
  clReleaseKernel(kernel);
  clReleaseProgram(program);
  clReleaseCommandQueue(queue);
  clReleaseContext(context);
}

static void rng_scalar_kernel_runner(
    const std::string&         kernel_source,
    const char*                kernel_name,
    const std::vector<double>& dargs,
    int                        n_out,
    std::vector<double>&       out_flat
) {
  out_flat.assign(static_cast<size_t>(n_out), 0.0);

  cl_int status = 0;
  std::string build_log;

  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step << " (status=" << s << ").";
      throw std::runtime_error(msg.str());
    }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  status = clGetPlatformIDs(1, &platform, nullptr);
  if (status == -1001) {
    throw std::runtime_error(
      "OpenCL error: no OpenCL platforms found (clGetPlatformIDs returned -1001)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetPlatformIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }

  status = clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, nullptr);
  if (status == -9) {
    throw std::runtime_error(
      "OpenCL error: no suitable OpenCL devices found (clGetDeviceIDs returned -9)."
    );
  }
  if (status != CL_SUCCESS) {
    std::ostringstream msg;
    msg << "OpenCL error: clGetDeviceIDs failed with status " << status << ".";
    throw std::runtime_error(msg.str());
  }

  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  if (status != CL_SUCCESS) {
    throw make_context_error(status, platform, device);
  }

  cl_queue_properties props[] = {0};
  cl_command_queue queue = clCreateCommandQueueWithProperties(context, device, props, &status);
  require_success(status, "clCreateCommandQueueWithProperties");

  const char* src_ptr = kernel_source.c_str();
  size_t src_len = kernel_source.size();
  cl_program program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
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
    msg << "OpenCL error at clBuildProgram (status=" << status << ").";
    if (!build_log.empty()) msg << "\nBuild log:\n" << build_log;
    throw std::runtime_error(msg.str());
  }

  cl_kernel kernel = clCreateKernel(program, kernel_name, &status);
  require_success(status, "clCreateKernel");

  cl_mem bufOut = clCreateBuffer(
      context, CL_MEM_WRITE_ONLY,
      sizeof(double) * out_flat.size(), nullptr, &status
  );
  require_success(status, "clCreateBuffer(bufOut)");

  int arg = 0;
  for (double val : dargs) {
    status = clSetKernelArg(kernel, arg++, sizeof(double), &val);
    require_success(status, "clSetKernelArg(double)");
  }
  status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &bufOut);
  require_success(status, "clSetKernelArg(bufOut)");
  status = clSetKernelArg(kernel, arg++, sizeof(int), &n_out);
  require_success(status, "clSetKernelArg(n_out)");

  const size_t global = 1;
  status = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
  require_success(status, "clEnqueueNDRangeKernel");

  status = clEnqueueReadBuffer(
      queue, bufOut, CL_TRUE, 0,
      sizeof(double) * out_flat.size(), out_flat.data(),
      0, nullptr, nullptr
  );
  require_success(status, "clEnqueueReadBuffer(out)");

  clFlush(queue);
  clFinish(queue);

  clReleaseMemObject(bufOut);
  clReleaseKernel(kernel);
  clReleaseProgram(program);
  clReleaseCommandQueue(queue);
  clReleaseContext(context);
}

void runif_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               a,
    double               b,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {a, b}, n, out_flat);
}

void rnorm_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               mu,
    double               sigma,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {mu, sigma}, n, out_flat);
}

void rexp_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               scale,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {scale}, n, out_flat);
}

void rwilcox_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               m,
    double               n2,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {m, n2}, n_out, out_flat);
}

void rbinom_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               size,
    double               prob,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {size, prob}, n_out, out_flat);
}

void rmath_runtime_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               x,
    double               y,
    double               z,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {x, y, z}, n_out, out_flat);
}

void rmath_rng_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               a,
    double               b,
    double               index_upper,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {a, b, index_upper}, n_out, out_flat);
}

void rmath_discrete_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               size,
    double               prob,
    double               lambda,
    double               mu,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {size, prob, lambda, mu}, n_out, out_flat);
}

void rmath_noncentral_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               x,
    double               df,
    double               ncp,
    double               df2,
    double               p,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {x, df, ncp, df2, p}, n_out, out_flat);
}

void rext_utils_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {}, n_out, out_flat);
}

}
}

#endif

