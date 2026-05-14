

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
      msg << "OpenCL error at " << step
          << " (status=" << s
          << ", name=" << opencl_status_name(s) << "). "
          << opencl_status_hint(s);
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
    msg << "OpenCL error: clGetPlatformIDs failed with status " << status
        << " (" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
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
    msg << "OpenCL error: clGetDeviceIDs failed with status " << status
        << " (" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
    throw std::runtime_error(msg.str());
  }

  cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
  if (status != CL_SUCCESS) {
    throw opencl_make_context_error(status, platform, device);
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
    msg << "OpenCL error at clBuildProgram (status=" << status
        << ", name=" << opencl_status_name(status) << "). "
        << opencl_status_hint(status);
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
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
  cl_mem bufOut = nullptr;

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

  auto cleanup = [&]() {
    if (bufOut) { clReleaseMemObject(bufOut); bufOut = nullptr; }
    if (kernel) { clReleaseKernel(kernel); kernel = nullptr; }
    if (program) { clReleaseProgram(program); program = nullptr; }
    if (queue) { clReleaseCommandQueue(queue); queue = nullptr; }
    if (context) { clReleaseContext(context); context = nullptr; }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  try {
    status = clGetPlatformIDs(1, &platform, nullptr);
    if (status == -1001) {
      throw std::runtime_error(
        "OpenCL error: no OpenCL platforms found (clGetPlatformIDs returned -1001)."
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
        "OpenCL error: no suitable OpenCL devices found (clGetDeviceIDs returned -9)."
      );
    }
    if (status != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error: clGetDeviceIDs failed with status " << status
          << " (" << opencl_status_name(status) << "). "
          << opencl_status_hint(status);
      throw std::runtime_error(msg.str());
    }

    context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
    if (status != CL_SUCCESS) {
      throw opencl_make_context_error(status, platform, device);
    }

    cl_queue_properties props[] = {0};
    queue = clCreateCommandQueueWithProperties(context, device, props, &status);
    require_success(status, "clCreateCommandQueueWithProperties");

    const char* src_ptr = kernel_source.c_str();
    size_t src_len = kernel_source.size();
    program = clCreateProgramWithSource(context, 1, &src_ptr, &src_len, &status);
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
      if (!build_log.empty()) msg << "\nBuild log:\n" << build_log;
      throw std::runtime_error(msg.str());
    }

    kernel = clCreateKernel(program, kernel_name, &status);
    require_success(status, "clCreateKernel");

    bufOut = clCreateBuffer(
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

    cleanup();
  } catch (...) {
    cleanup();
    throw;
  }
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

void rmath_distribution_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               a,
    double               b,
    double               c,
    double               d,
    double               e,
    std::vector<double>& out_flat
) {
  rng_scalar_kernel_runner(kernel_source, kernel_name, {a, b, c, d, e}, n_out, out_flat);
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

