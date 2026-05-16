/**
 * @file openclPort.h
 * @brief Public OpenCL interface for glmbayes, including kernel loading,
 *        device discovery, capability probing, and Rcpp-to-std::vector
 *        conversion helpers.
 *
 * @namespace openclPort
 * @brief Lightweight OpenCL utility layer providing kernel management and
 *        device‑level information for optional GPU acceleration.
 *
 * @section ImplementedIn
 *   These declarations are implemented in:
 *     - OpenCL_helper.cpp
 *     - opencl_detect.cpp
 *     - kernel_loader.cpp
 *     - (optional) additional OpenCL backend files guarded by USE_OPENCL
 *
 * @section UsedBy
 *   These functions are consumed by:
 *     - Envelope construction routines (EnvelopeBuild, EnvelopeEval,
 *       EnvelopeDispersionBuild) when OpenCL acceleration is enabled
 *     - R wrappers that expose GPU availability and kernel loading to users
 *
 * @section Responsibilities
 *   Provides:
 *     - Rcpp → std::vector conversion utilities for kernel argument buffers
 *     - GPU/device enumeration and capability checks (gpu_names, has_opencl)
 *     - Kernel source and library loading from inst/cl/ directories
 *     - Conditional OpenCL configuration and build‑option generation
 *
 *   This module:
 *     - is optional and only active when compiled with USE_OPENCL,
 *     - isolates all OpenCL‑specific logic from the statistical code,
 *     - ensures safe fallback to CPU execution when no GPU is available.
 */


#ifndef OPENCLPORT_H
#define OPENCLPORT_H

#include <RcppArmadillo.h>
#include <string>
#include <vector>

#ifdef USE_OPENCL

// Ensure OpenCL types are available
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#include <string>
#endif 

#ifdef __linux__
#include <stdio.h>
#include <stdlib.h>
#endif

using namespace Rcpp;

// Dependencies:

// 1) OpenCL_helper.cpp
// 2) 



//
// -----------------------------------------------------------------------------
// openclPort: Public API for OpenCL kernel loading, device utilities,
//             and Rcpp → std::vector conversion helpers.
// -----------------------------------------------------------------------------
// Everything a user needs to write OpenCL-enabled wrappers lives here.
// -----------------------------------------------------------------------------
namespace openclPort {

// -------------------------------------------------------------------------
// Rcpp → std::vector conversion utilities
// -------------------------------------------------------------------------
std::vector<double> flattenMatrix(const Rcpp::NumericMatrix& mat);
std::vector<double> copyVector(const Rcpp::NumericVector& vec);

// -------------------------------------------------------------------------
// Device / OpenCL utilities
// -------------------------------------------------------------------------
Rcpp::CharacterVector gpu_names();

// Internal-only GPU detection (used by envelope scaling)
int detect_num_gpus_internal();


// -------------------------------------------------------------------------
// R-facing wrappers for kernel source loading
// -------------------------------------------------------------------------
std::string load_kernel_source_wrapper(
    std::string relative_path,
    std::string package = "nmathopencl"
);

std::string load_kernel_library_wrapper(
    std::string subdir,
    std::string package = "nmathopencl",
    bool verbose = false
);

// -------------------------------------------------------------------------
// Device / OpenCL utilities
// -------------------------------------------------------------------------

bool has_opencl();
int get_opencl_core_count();


// -------------------------------------------------------------------------
// Conditional declarations: only available when USE_OPENCL is defined
// -------------------------------------------------------------------------
#ifdef USE_OPENCL

// Ensure OpenCL types are available
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#include <string>
#include <sstream>
#include <stdexcept>


// Load a single .cl kernel file from inst/cl/<relative_path>
std::string load_kernel_source(
    const std::string& relative_path,
    const std::string& package = "nmathopencl"
);

// Load and concatenate all .cl files in a subdirectory (inst/cl/<subdir>/)
std::string load_kernel_library(
    const std::string& subdir,
    const std::string& package = "nmathopencl",
    bool verbose = false
);

// Load only the library files required by a specific kernel, in dependency
// order, using the pre-built kernel_dependency_index.tsv.  No topological
// sort at runtime.  Returns "" if the kernel has no @{depends_tag} annotation.
std::string load_library_for_kernel(
    const std::string& kernel_relative_path,
    const std::string& library_subdir,
    const std::string& package    = "nmathopencl",
    const std::string& depends_tag = "depends_nmath"
);

// True if the kernel's `// @all_depends_nmath:` line lists stem `qDiscrete_search`.
bool kernel_all_depends_nmath_includes_qDiscrete_search(
    const std::string& kernel_relative_path,
    const std::string& package = "nmathopencl");

struct OpenCLConfig {
  bool have_expm1;
  bool have_log1p;
  std::string buildOptions;
};

// Probe OpenCL device capabilities and construct build options
OpenCLConfig configureOpenCL(cl_context context,
                             cl_device_id device);

// -------------------------------------------------------------------------
// Generic double-scalar kernel runner
// Runs any OpenCL kernel whose argument layout is:
//   kernel(double arg0, ..., double argN, __global double* out, int n_out)
// dargs   : scalar double inputs (any count, including zero)
// n_out   : number of output doubles to read back
// out_flat: output buffer (resized to n_out on entry)
// -------------------------------------------------------------------------
void opencl_dbl_scalar_kernel_runner(
    const std::string&         kernel_source,
    const char*                kernel_name,
    const std::vector<double>& dargs,
    int                        n_out,
    std::vector<double>&       out_flat
);

// -------------------------------------------------------------------------
// OpenCL error-handling utilities
// (inline so downstream packages get them via #include "openclPort.h")
// -------------------------------------------------------------------------

inline const char* opencl_status_name(cl_int status) {
  switch (status) {
    case CL_SUCCESS:                     return "CL_SUCCESS";
    case CL_DEVICE_NOT_FOUND:            return "CL_DEVICE_NOT_FOUND";
    case CL_DEVICE_NOT_AVAILABLE:        return "CL_DEVICE_NOT_AVAILABLE";
    case CL_COMPILER_NOT_AVAILABLE:      return "CL_COMPILER_NOT_AVAILABLE";
    case CL_MEM_OBJECT_ALLOCATION_FAILURE: return "CL_MEM_OBJECT_ALLOCATION_FAILURE";
    case CL_OUT_OF_RESOURCES:            return "CL_OUT_OF_RESOURCES";
    case CL_OUT_OF_HOST_MEMORY:          return "CL_OUT_OF_HOST_MEMORY";
    case CL_BUILD_PROGRAM_FAILURE:       return "CL_BUILD_PROGRAM_FAILURE";
    case CL_INVALID_VALUE:               return "CL_INVALID_VALUE";
    case CL_INVALID_DEVICE:              return "CL_INVALID_DEVICE";
    case CL_INVALID_BINARY:              return "CL_INVALID_BINARY";
    case CL_INVALID_BUILD_OPTIONS:       return "CL_INVALID_BUILD_OPTIONS";
    case CL_INVALID_PROGRAM:             return "CL_INVALID_PROGRAM";
    case CL_INVALID_OPERATION:           return "CL_INVALID_OPERATION";
    case CL_INVALID_PLATFORM:            return "CL_INVALID_PLATFORM";
    case CL_INVALID_CONTEXT:             return "CL_INVALID_CONTEXT";
    default:                             return "UNKNOWN_OR_VENDOR_SPECIFIC";
  }
}

inline const char* opencl_status_hint(cl_int status) {
  switch (status) {
    case CL_OUT_OF_RESOURCES:
      return "Device/runtime resource limit exceeded (often kernel execution failure, watchdog timeout, or register/local-memory pressure).";
    case CL_OUT_OF_HOST_MEMORY:
      return "Host memory allocation failed while interacting with OpenCL runtime.";
    case CL_MEM_OBJECT_ALLOCATION_FAILURE:
      return "Device memory allocation failed for one or more buffers.";
    case CL_BUILD_PROGRAM_FAILURE:
      return "Kernel compilation/build failed; inspect CL_PROGRAM_BUILD_LOG.";
    case CL_INVALID_CONTEXT:
      return "OpenCL context is invalid; may indicate stale runtime state.";
    case CL_INVALID_DEVICE:
      return "Selected OpenCL device is invalid for this operation.";
    case CL_DEVICE_NOT_AVAILABLE:
      return "OpenCL device is present but temporarily unavailable.";
    default:
      return "No additional hint available.";
  }
}

inline std::string opencl_read_platform_info_str(cl_platform_id platform, cl_platform_info param) {
  if (platform == nullptr) return "unknown";
  size_t n = 0;
  if (clGetPlatformInfo(platform, param, 0, nullptr, &n) != CL_SUCCESS || n == 0) return "unknown";
  std::string out(n, '\0');
  if (clGetPlatformInfo(platform, param, n, &out[0], nullptr) != CL_SUCCESS) return "unknown";
  if (!out.empty() && out.back() == '\0') out.pop_back();
  return out.empty() ? "unknown" : out;
}

inline std::string opencl_read_device_info_str(cl_device_id device, cl_device_info param) {
  if (device == nullptr) return "unknown";
  size_t n = 0;
  if (clGetDeviceInfo(device, param, 0, nullptr, &n) != CL_SUCCESS || n == 0) return "unknown";
  std::string out(n, '\0');
  if (clGetDeviceInfo(device, param, n, &out[0], nullptr) != CL_SUCCESS) return "unknown";
  if (!out.empty() && out.back() == '\0') out.pop_back();
  return out.empty() ? "unknown" : out;
}

inline std::runtime_error opencl_make_context_error(cl_int status, cl_platform_id platform, cl_device_id device) {
  std::ostringstream msg;
  msg << "OpenCL error at clCreateContext (status=" << status
      << ", name=" << opencl_status_name(status) << "). "
      << "platform_name=" << opencl_read_platform_info_str(platform, CL_PLATFORM_NAME)
      << ", platform_vendor=" << opencl_read_platform_info_str(platform, CL_PLATFORM_VENDOR)
      << ", device_name=" << opencl_read_device_info_str(device, CL_DEVICE_NAME)
      << ", driver_version=" << opencl_read_device_info_str(device, CL_DRIVER_VERSION)
      << ". This may indicate a transient driver/runtime context failure.";
  return std::runtime_error(msg.str());
}

#endif // USE_OPENCL



} // namespace openclPort

#endif // OPENCLPORT_H


