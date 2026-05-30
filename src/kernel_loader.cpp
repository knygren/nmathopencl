#include <RcppArmadillo.h>
#include "openclPort.h"

#include <algorithm>
#include <string>

#include <opencltools/opencltools_capi.h>

namespace openclPort {

namespace {

std::string opencltools_take_cstr(const char* p) {
  if (p == nullptr) {
    return std::string();
  }
  std::string out(p);
  opencltools_free_cstr(p);
  return out;
}

} // namespace

std::string load_kernel_source(const std::string& relative_path,
                               const std::string& package) {
  return opencltools_take_cstr(
      opencltools_load_kernel_source(relative_path.c_str(), package.c_str()));
}

std::string load_kernel_library(const std::string& subdir,
                                const std::string& package,
                                bool verbose) {
  return opencltools_take_cstr(
      opencltools_load_kernel_library(subdir.c_str(), package.c_str(),
                                      verbose ? 1 : 0));
}

std::string load_library_for_kernel(
    const std::string& kernel_relative_path,
    const std::string& library_subdir,
    const std::string& package,
    const std::string& depends_tag) {
  return opencltools_take_cstr(opencltools_load_library_for_kernel(
      kernel_relative_path.c_str(), library_subdir.c_str(), package.c_str(),
      depends_tag.c_str()));
}

std::string build_rmath_opencl_program(const std::string& kernel_relative_path,
                                       const std::string& package,
                                       const std::string& nmath_depends_annotation) {
  const std::string nmath_src = load_library_for_kernel(
      kernel_relative_path,
      "nmath",
      package,
      nmath_depends_annotation);

  return load_kernel_source("OPENCL.cl", package) +
         "\n" + load_kernel_library("libR_shims", package, false) +
         "\n" + load_kernel_library("R_ext_types", package, false) +
         "\n" + load_kernel_library("R_shims", package, false) +
         "\n" + load_kernel_library("R_ext_runtime", package, false) +
         "\n" + load_kernel_library("R_ext_internals", package, false) +
         "\n" + load_kernel_library("System", package, false) + "\n" + nmath_src +
         "\n" + load_kernel_source(kernel_relative_path, package);
}

int get_opencl_core_count() {
  return std::max(1, opencltools_get_opencl_core_count());
}

std::string load_kernel_source_wrapper(std::string relative_path,
                                       std::string package) {
  return load_kernel_source(relative_path, package);
}

std::string load_kernel_library_wrapper(std::string subdir,
                                        std::string package,
                                        bool verbose) {
  return load_kernel_library(subdir, package, verbose);
}

} // namespace openclPort
