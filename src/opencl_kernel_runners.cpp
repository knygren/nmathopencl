#ifdef USE_OPENCL

#ifdef USE_DIRECT_CLH
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#else
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#endif
#endif

#include "openclPort.h"
#include <vector>
#include <string>
#include <sstream>
#include <stdexcept>

#ifdef USE_OPENCL

// =============================================================================
// openclPort: generic double-scalar kernel runner
// =============================================================================
namespace openclPort {

void opencl_dbl_scalar_kernel_runner(
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
    opencl_bind_selected_fp64_device_or_throw(platform, device);

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

void opencl_pq_tail_kernel_runner(
    const std::string&                     kernel_source,
    const char*                            kernel_name,
    int                                    len,
    const std::vector<std::vector<double>>& arg_cols,
    const std::vector<int>&                lower_tail,
    const std::vector<int>&                log_p,
    std::vector<double>&                   out_flat
) {
  out_flat.assign(static_cast<size_t>(len), 0.0);
  if (len <= 0) return;

  const int k = static_cast<int>(arg_cols.size());
  if (k < 1) {
    throw std::runtime_error("opencl_pq_tail_kernel_runner: arg_cols must be non-empty.");
  }
  for (int j = 0; j < k; ++j) {
    if ((int)arg_cols[static_cast<size_t>(j)].size() != len) {
      throw std::runtime_error("opencl_pq_tail_kernel_runner: argument column size mismatch.");
    }
  }
  if ((int)lower_tail.size() != len || (int)log_p.size() != len) {
    throw std::runtime_error(
        "opencl_pq_tail_kernel_runner: lower_tail / log_p size mismatch.");
  }

  cl_int status = 0;
  std::string build_log;
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
  std::vector<cl_mem> buf_cols(static_cast<size_t>(k), nullptr);
  cl_mem buf_lt = nullptr;
  cl_mem buf_lp = nullptr;
  cl_mem buf_out = nullptr;

  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step
          << " (status=" << s << ", name=" << opencl_status_name(s) << "). "
          << opencl_status_hint(s);
      throw std::runtime_error(msg.str());
    }
  };

  auto cleanup = [&]() {
    if (buf_out) {
      clReleaseMemObject(buf_out);
      buf_out = nullptr;
    }
    if (buf_lp) {
      clReleaseMemObject(buf_lp);
      buf_lp = nullptr;
    }
    if (buf_lt) {
      clReleaseMemObject(buf_lt);
      buf_lt = nullptr;
    }
    for (auto& b : buf_cols) {
      if (b) {
        clReleaseMemObject(b);
        b = nullptr;
      }
    }
    if (kernel) {
      clReleaseKernel(kernel);
      kernel = nullptr;
    }
    if (program) {
      clReleaseProgram(program);
      program = nullptr;
    }
    if (queue) {
      clReleaseCommandQueue(queue);
      queue = nullptr;
    }
    if (context) {
      clReleaseContext(context);
      context = nullptr;
    }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  try {
    opencl_bind_selected_fp64_device_or_throw(platform, device);

    context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
    if (status != CL_SUCCESS) throw opencl_make_context_error(status, platform, device);

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
      cl_int s1 =
          clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, log_size, &log[0], nullptr);
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

    for (int j = 0; j < k; ++j) {
      const auto& col = arg_cols[static_cast<size_t>(j)];
      buf_cols[static_cast<size_t>(j)] =
          clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                         sizeof(double) * static_cast<size_t>(len),
                         (void*)col.data(), &status);
      require_success(status, "clCreateBuffer(arg_col)");
    }

    buf_lt =
        clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                       sizeof(int) * static_cast<size_t>(len), (void*)lower_tail.data(), &status);
    require_success(status, "clCreateBuffer(lower_tail)");
    buf_lp =
        clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                       sizeof(int) * static_cast<size_t>(len), (void*)log_p.data(), &status);
    require_success(status, "clCreateBuffer(log_p)");

    buf_out = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                             sizeof(double) * static_cast<size_t>(len), nullptr, &status);
    require_success(status, "clCreateBuffer(out)");

    int arg = 0;
    for (int j = 0; j < k; ++j) {
      status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_cols[static_cast<size_t>(j)]);
      require_success(status, "clSetKernelArg(arg_col)");
    }
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_lt);
    require_success(status, "clSetKernelArg(lower_tail)");
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_lp);
    require_success(status, "clSetKernelArg(log_p)");
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_out);
    require_success(status, "clSetKernelArg(out)");
    status = clSetKernelArg(kernel, arg++, sizeof(int), &len);
    require_success(status, "clSetKernelArg(len)");

    size_t global = static_cast<size_t>(len);
    status =
        clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
    require_success(status, "clEnqueueNDRangeKernel");

    status = clEnqueueReadBuffer(queue, buf_out, CL_TRUE, 0,
                                 sizeof(double) * static_cast<size_t>(len), out_flat.data(), 0,
                                 nullptr, nullptr);
    require_success(status, "clEnqueueReadBuffer(out)");

    clFlush(queue);
    clFinish(queue);

    cleanup();
  } catch (...) {
    cleanup();
    throw;
  }
}

void opencl_d_givelog_kernel_runner(
    const std::string&                     kernel_source,
    const char*                            kernel_name,
    int                                    len,
    const std::vector<std::vector<double>>& arg_cols,
    const std::vector<int>&                give_log,
    std::vector<double>&                   out_flat
) {
  out_flat.assign(static_cast<size_t>(len), 0.0);
  if (len <= 0) return;

  const int k = static_cast<int>(arg_cols.size());
  if (k < 1) {
    throw std::runtime_error("opencl_d_givelog_kernel_runner: arg_cols must be non-empty.");
  }
  for (int j = 0; j < k; ++j) {
    if ((int)arg_cols[static_cast<size_t>(j)].size() != len) {
      throw std::runtime_error("opencl_d_givelog_kernel_runner: argument column size mismatch.");
    }
  }
  if ((int)give_log.size() != len) {
    throw std::runtime_error("opencl_d_givelog_kernel_runner: give_log size mismatch.");
  }

  cl_int status = 0;
  std::string build_log;
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
  std::vector<cl_mem> buf_cols(static_cast<size_t>(k), nullptr);
  cl_mem buf_gl = nullptr;
  cl_mem buf_out = nullptr;

  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step
          << " (status=" << s << ", name=" << opencl_status_name(s) << "). "
          << opencl_status_hint(s);
      throw std::runtime_error(msg.str());
    }
  };

  auto cleanup = [&]() {
    if (buf_out) {
      clReleaseMemObject(buf_out);
      buf_out = nullptr;
    }
    if (buf_gl) {
      clReleaseMemObject(buf_gl);
      buf_gl = nullptr;
    }
    for (auto& b : buf_cols) {
      if (b) {
        clReleaseMemObject(b);
        b = nullptr;
      }
    }
    if (kernel) {
      clReleaseKernel(kernel);
      kernel = nullptr;
    }
    if (program) {
      clReleaseProgram(program);
      program = nullptr;
    }
    if (queue) {
      clReleaseCommandQueue(queue);
      queue = nullptr;
    }
    if (context) {
      clReleaseContext(context);
      context = nullptr;
    }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  try {
    opencl_bind_selected_fp64_device_or_throw(platform, device);

    context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
    if (status != CL_SUCCESS) throw opencl_make_context_error(status, platform, device);

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
      cl_int s1 =
          clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, log_size, &log[0], nullptr);
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

    for (int j = 0; j < k; ++j) {
      const auto& col = arg_cols[static_cast<size_t>(j)];
      buf_cols[static_cast<size_t>(j)] =
          clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                         sizeof(double) * static_cast<size_t>(len),
                         (void*)col.data(), &status);
      require_success(status, "clCreateBuffer(arg_col)");
    }

    buf_gl =
        clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                       sizeof(int) * static_cast<size_t>(len), (void*)give_log.data(), &status);
    require_success(status, "clCreateBuffer(give_log)");

    buf_out = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                             sizeof(double) * static_cast<size_t>(len), nullptr, &status);
    require_success(status, "clCreateBuffer(out)");

    int arg = 0;
    for (int j = 0; j < k; ++j) {
      status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_cols[static_cast<size_t>(j)]);
      require_success(status, "clSetKernelArg(arg_col)");
    }
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_gl);
    require_success(status, "clSetKernelArg(give_log)");
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_out);
    require_success(status, "clSetKernelArg(out)");
    status = clSetKernelArg(kernel, arg++, sizeof(int), &len);
    require_success(status, "clSetKernelArg(len)");

    size_t global = static_cast<size_t>(len);
    status =
        clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
    require_success(status, "clEnqueueNDRangeKernel");

    status = clEnqueueReadBuffer(queue, buf_out, CL_TRUE, 0,
                                 sizeof(double) * static_cast<size_t>(len), out_flat.data(), 0,
                                 nullptr, nullptr);
    require_success(status, "clEnqueueReadBuffer(out)");

    clFlush(queue);
    clFinish(queue);

    cleanup();
  } catch (...) {
    cleanup();
    throw;
  }
}

void opencl_numeric_cols_kernel_runner(
    const std::string&                     kernel_source,
    const char*                            kernel_name,
    int                                    len,
    const std::vector<std::vector<double>>& arg_cols,
    std::vector<double>&                   out_flat
) {
  out_flat.assign(static_cast<size_t>(len), 0.0);
  if (len <= 0) return;

  const int k = static_cast<int>(arg_cols.size());
  if (k < 1) {
    throw std::runtime_error("opencl_numeric_cols_kernel_runner: arg_cols must be non-empty.");
  }
  for (int j = 0; j < k; ++j) {
    if ((int)arg_cols[static_cast<size_t>(j)].size() != len) {
      throw std::runtime_error("opencl_numeric_cols_kernel_runner: argument column size mismatch.");
    }
  }

  cl_int status = 0;
  std::string build_log;
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
  std::vector<cl_mem> buf_cols(static_cast<size_t>(k), nullptr);
  cl_mem buf_out = nullptr;

  auto require_success = [&](cl_int s, const char* step) {
    if (s != CL_SUCCESS) {
      std::ostringstream msg;
      msg << "OpenCL error at " << step
          << " (status=" << s << ", name=" << opencl_status_name(s) << "). "
          << opencl_status_hint(s);
      throw std::runtime_error(msg.str());
    }
  };

  auto cleanup = [&]() {
    if (buf_out) {
      clReleaseMemObject(buf_out);
      buf_out = nullptr;
    }
    for (auto& b : buf_cols) {
      if (b) {
        clReleaseMemObject(b);
        b = nullptr;
      }
    }
    if (kernel) {
      clReleaseKernel(kernel);
      kernel = nullptr;
    }
    if (program) {
      clReleaseProgram(program);
      program = nullptr;
    }
    if (queue) {
      clReleaseCommandQueue(queue);
      queue = nullptr;
    }
    if (context) {
      clReleaseContext(context);
      context = nullptr;
    }
  };

  cl_platform_id platform = nullptr;
  cl_device_id   device   = nullptr;

  try {
    opencl_bind_selected_fp64_device_or_throw(platform, device);

    context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, &status);
    if (status != CL_SUCCESS) throw opencl_make_context_error(status, platform, device);

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
      cl_int s1 =
          clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, log_size, &log[0], nullptr);
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

    for (int j = 0; j < k; ++j) {
      const auto& col = arg_cols[static_cast<size_t>(j)];
      buf_cols[static_cast<size_t>(j)] =
          clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                         sizeof(double) * static_cast<size_t>(len),
                         (void*)col.data(), &status);
      require_success(status, "clCreateBuffer(arg_col)");
    }

    buf_out = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                             sizeof(double) * static_cast<size_t>(len), nullptr, &status);
    require_success(status, "clCreateBuffer(out)");

    int arg = 0;
    for (int j = 0; j < k; ++j) {
      status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_cols[static_cast<size_t>(j)]);
      require_success(status, "clSetKernelArg(arg_col)");
    }
    status = clSetKernelArg(kernel, arg++, sizeof(cl_mem), &buf_out);
    require_success(status, "clSetKernelArg(out)");
    status = clSetKernelArg(kernel, arg++, sizeof(int), &len);
    require_success(status, "clSetKernelArg(len)");

    size_t global = static_cast<size_t>(len);
    status =
        clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0, nullptr, nullptr);
    require_success(status, "clEnqueueNDRangeKernel");

    status = clEnqueueReadBuffer(queue, buf_out, CL_TRUE, 0,
                                 sizeof(double) * static_cast<size_t>(len), out_flat.data(), 0,
                                 nullptr, nullptr);
    require_success(status, "clEnqueueReadBuffer(out)");

    clFlush(queue);
    clFinish(queue);

    cleanup();
  } catch (...) {
    cleanup();
    throw;
  }
}

void opencl_pnorm_kernel_runner(
    const std::string&         kernel_source,
    const char*                kernel_name,
    int                        len,
    const std::vector<double>& q,
    const std::vector<double>& mean,
    const std::vector<double>& sd,
    const std::vector<int>&    lower_tail,
    const std::vector<int>&    log_p,
    std::vector<double>&       out_flat
) {
  opencl_pq_tail_kernel_runner(
      kernel_source,
      kernel_name,
      len,
      std::vector<std::vector<double>>{q, mean, sd},
      lower_tail,
      log_p,
      out_flat);
}

} // namespace openclPort

#endif
