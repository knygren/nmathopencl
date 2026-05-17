

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
#include "nmathopencl.h"
#include <vector>
#include <string>

using namespace openclPort;

#ifdef USE_OPENCL

// =============================================================================
// nmathopencl: distribution-specific kernel runners
// =============================================================================
namespace nmathopencl {

void runif_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               a,
    double               b,
    std::vector<double>& out_flat
) {
  opencl_dbl_scalar_kernel_runner(kernel_source, kernel_name, {a, b}, n, out_flat);
}

void rnorm_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               mu,
    double               sigma,
    std::vector<double>& out_flat
) {
  opencl_dbl_scalar_kernel_runner(kernel_source, kernel_name, {mu, sigma}, n, out_flat);
}

void rexp_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               scale,
    std::vector<double>& out_flat
) {
  opencl_dbl_scalar_kernel_runner(kernel_source, kernel_name, {scale}, n, out_flat);
}

void rwilcox_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               m,
    double               n2,
    std::vector<double>& out_flat
) {
  opencl_dbl_scalar_kernel_runner(kernel_source, kernel_name, {m, n2}, n_out, out_flat);
}

void rbinom_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               size,
    double               prob,
    std::vector<double>& out_flat
) {
  opencl_dbl_scalar_kernel_runner(kernel_source, kernel_name, {size, prob}, n_out, out_flat);
}

} // namespace nmathopencl

#endif

