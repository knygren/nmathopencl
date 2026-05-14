/**
 * @file ex_glmbayes_opencl.h
 * @brief GLM-specific OpenCL execution layer for the glmbayes example.
 *        Declares GPU runners and Rcpp wrappers for f2/f3 log-posterior
 *        and gradient evaluation.
 *
 * @namespace ex_glmbayes::opencl
 *
 * @section ImplementedIn
 *   ex_glmbayes_kernel_runners.cpp, ex_glmbayes_kernel_wrappers.cpp
 *
 * @section UsedBy
 *   ex_glmbayes_EnvelopeEval.cpp, ex_glmbayes_kernel_wrappers.cpp,
 *   ex_glmbayes_kernel_runners.cpp
 */

#ifndef EX_GLMBAYES_OPENCL_H
#define EX_GLMBAYES_OPENCL_H

#include <string>
#include <vector>
#include <Rcpp.h>

namespace ex_glmbayes {
namespace opencl {

void f2_f3_kernel_runner(
    const std::string&            kernel_source,
    const char*                   kernel_name,
    int                           l1,
    int                           l2,
    int                           m1,
    const std::vector<double>&    X_flat,
    const std::vector<double>&    B_flat,
    const std::vector<double>&    mu_flat,
    const std::vector<double>&    P_flat,
    const std::vector<double>&    alpha_flat,
    const std::vector<double>&    y_flat,
    const std::vector<double>&    wt_flat,
    std::vector<double>&          qf_flat,
    std::vector<double>&          grad_flat,
    int                           progbar = 0
);

Rcpp::List f2_f3_opencl(
    std::string          family,
    std::string          link,
    Rcpp::NumericMatrix  b,
    Rcpp::NumericVector  y,
    Rcpp::NumericMatrix  x,
    Rcpp::NumericMatrix  mu,
    Rcpp::NumericMatrix  P,
    Rcpp::NumericVector  alpha,
    Rcpp::NumericVector  wt,
    int                  progbar = 0
);

} // namespace opencl
} // namespace ex_glmbayes

#endif // EX_GLMBAYES_OPENCL_H
