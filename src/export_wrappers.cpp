#include "RcppArmadillo.h"
#include "openclPort.h"
#include "nmathopencl.h"

using namespace openclPort;


// -----------------------------------------------------------------------------
// Wrapper organization mirrors R/rcpp_wrappers.R:
//   Tier 5: OpenCL/GPU - nmath function runners, kernel loading, diagnostics
//
// Example-specific wrappers (EnvelopeSize, EnvelopeEval, glmb_Standardize_Model)
// have been moved to ex_glmbayes_export_wrappers.cpp.
// -----------------------------------------------------------------------------



// =============================================================================
// Tier 5: OpenCL / GPU
// Callers: load_kernel_source, load_kernel_library, has_opencl,
//          get_opencl_core_count, gpu_names
// User:    Advanced users - GPU diagnostics, kernel loading for use_opencl
// =============================================================================

// [[Rcpp::export]]
Rcpp::NumericVector dnorm_opencl_cpp_export(
    const Rcpp::NumericVector& x,
    double mu = 0.0,
    double sigma = 1.0,
    bool give_log = false,
    bool verbose = false
) {
  return nmathopencl::dnorm_opencl(x, mu, sigma, give_log, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector runif_opencl_cpp_export(
    int n,
    double a = 0.0,
    double b = 1.0,
    bool verbose = false
) {
  return nmathopencl::runif_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnorm_opencl_cpp_export(
    int n,
    double mu = 0.0,
    double sigma = 1.0,
    bool verbose = false
) {
  return nmathopencl::rnorm_opencl(n, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rexp_opencl_cpp_export(
    int n,
    double scale = 1.0,
    bool verbose = false
) {
  return nmathopencl::rexp_opencl(n, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rwilcox_opencl_cpp_export(
    int n,
    double m,
    double n2,
    bool verbose = false
) {
  return nmathopencl::rwilcox_opencl(n, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rbinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::rbinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_pow_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::r_pow_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_pow_di_opencl_cpp_export(
    int n,
    double x,
    int n_exp,
    bool verbose = false
) {
  return nmathopencl::r_pow_di_opencl(n, x, n_exp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1pmx_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::log1pmx_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1pexp_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::log1pexp_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1mexp_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::log1mexp_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgamma1p_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::lgamma1p_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pow1p_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::pow1p_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_add_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return nmathopencl::logspace_add_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_sub_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return nmathopencl::logspace_sub_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_sum_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return nmathopencl::logspace_sum_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector norm_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return nmathopencl::norm_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector unif_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return nmathopencl::unif_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_unif_index_opencl_cpp_export(
    int n,
    double dn,
    bool verbose = false
) {
  return nmathopencl::r_unif_index_opencl(n, dn, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector exp_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return nmathopencl::exp_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnorm_opencl_cpp_export(
    int n,
    double x,
    double mu,
    double sigma,
    bool verbose = false
) {
  return nmathopencl::pnorm_opencl(n, x, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnorm_opencl_cpp_export(
    int n,
    double p,
    double mu,
    double sigma,
    bool verbose = false
) {
  return nmathopencl::qnorm_opencl(n, p, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dunif_opencl_cpp_export(
    int n,
    double x,
    double min,
    double max,
    bool verbose = false
) {
  return nmathopencl::dunif_opencl(n, x, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector punif_opencl_cpp_export(
    int n,
    double x,
    double min,
    double max,
    bool verbose = false
) {
  return nmathopencl::punif_opencl(n, x, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qunif_opencl_cpp_export(
    int n,
    double p,
    double min,
    double max,
    bool verbose = false
) {
  return nmathopencl::qunif_opencl(n, p, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dgamma_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::dgamma_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pgamma_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::pgamma_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qgamma_opencl_cpp_export(
    int n,
    double p,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::qgamma_opencl(n, p, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rgamma_opencl_cpp_export(
    int n,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::rgamma_opencl(n, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::dbeta_opencl(n, x, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::pbeta_opencl(n, x, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qbeta_opencl_cpp_export(
    int n,
    double p,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::qbeta_opencl(n, p, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rbeta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::rbeta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dlnorm_opencl_cpp_export(
    int n,
    double x,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return nmathopencl::dlnorm_opencl(n, x, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector plnorm_opencl_cpp_export(
    int n,
    double q,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return nmathopencl::plnorm_opencl(n, q, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qlnorm_opencl_cpp_export(
    int n,
    double p,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return nmathopencl::qlnorm_opencl(n, p, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rlnorm_opencl_cpp_export(
    int n,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return nmathopencl::rlnorm_opencl(n, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return nmathopencl::dchisq_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return nmathopencl::pchisq_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qchisq_opencl_cpp_export(
    int n,
    double p,
    double df,
    bool verbose = false
) {
  return nmathopencl::qchisq_opencl(n, p, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rchisq_opencl_cpp_export(
    int n,
    double df,
    bool verbose = false
) {
  return nmathopencl::rchisq_opencl(n, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::dnchisq_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnchisq_opencl_cpp_export(
    int n,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::rnchisq_opencl(n, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector df_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    bool verbose = false
) {
  return nmathopencl::df_opencl(n, x, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pf_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    bool verbose = false
) {
  return nmathopencl::pf_opencl(n, x, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qf_opencl_cpp_export(
    int n,
    double p,
    double df1,
    double df2,
    bool verbose = false
) {
  return nmathopencl::qf_opencl(n, p, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rf_opencl_cpp_export(
    int n,
    double df1,
    double df2,
    bool verbose = false
) {
  return nmathopencl::rf_opencl(n, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dt_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return nmathopencl::dt_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pt_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return nmathopencl::pt_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qt_opencl_cpp_export(
    int n,
    double p,
    double df,
    bool verbose = false
) {
  return nmathopencl::qt_opencl(n, p, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rt_opencl_cpp_export(
    int n,
    double df,
    bool verbose = false
) {
  return nmathopencl::rt_opencl(n, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dbinom_raw_opencl_cpp_export(
    int n,
    double x,
    double n_size,
    double prob,
    double qprob,
    bool verbose = false
) {
  return nmathopencl::dbinom_raw_opencl(n, x, n_size, prob, qprob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dbinom_opencl_cpp_export(
    int n,
    double x,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::dbinom_opencl(n, x, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pbinom_opencl_cpp_export(
    int n,
    double q,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::pbinom_opencl(n, q, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnbinom_opencl_cpp_export(
    int n,
    double x,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::dnbinom_opencl(n, x, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnbinom_opencl_cpp_export(
    int n,
    double q,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::pnbinom_opencl(n, q, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnbinom_opencl_cpp_export(
    int n,
    double p,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::qnbinom_opencl(n, p, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnbinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::rnbinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnbinom_mu_opencl_cpp_export(
    int n,
    double x,
    double size,
    double mu,
    bool verbose = false
) {
  return nmathopencl::dnbinom_mu_opencl(n, x, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnbinom_mu_opencl_cpp_export(
    int n,
    double q,
    double size,
    double mu,
    bool verbose = false
) {
  return nmathopencl::pnbinom_mu_opencl(n, q, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rmultinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::rmultinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dcauchy_opencl_cpp_export(
    int n,
    double x,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::dcauchy_opencl(n, x, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pcauchy_opencl_cpp_export(
    int n,
    double q,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::pcauchy_opencl(n, q, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qcauchy_opencl_cpp_export(
    int n,
    double p,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::qcauchy_opencl(n, p, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rcauchy_opencl_cpp_export(
    int n,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::rcauchy_opencl(n, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dexp_opencl_cpp_export(
    int n,
    double x,
    double rate,
    bool verbose = false
) {
  return nmathopencl::dexp_opencl(n, x, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pexp_opencl_cpp_export(
    int n,
    double q,
    double rate,
    bool verbose = false
) {
  return nmathopencl::pexp_opencl(n, q, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qexp_opencl_cpp_export(
    int n,
    double p,
    double rate,
    bool verbose = false
) {
  return nmathopencl::qexp_opencl(n, p, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dgeom_opencl_cpp_export(
    int n,
    double x,
    double prob,
    bool verbose = false
) {
  return nmathopencl::dgeom_opencl(n, x, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pgeom_opencl_cpp_export(
    int n,
    double q,
    double prob,
    bool verbose = false
) {
  return nmathopencl::pgeom_opencl(n, q, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qgeom_opencl_cpp_export(
    int n,
    double p,
    double prob,
    bool verbose = false
) {
  return nmathopencl::qgeom_opencl(n, p, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rgeom_opencl_cpp_export(
    int n,
    double prob,
    bool verbose = false
) {
  return nmathopencl::rgeom_opencl(n, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dhyper_opencl_cpp_export(
    int n,
    double x,
    double r,
    double b,
    double n1,
    bool verbose = false
) {
  return nmathopencl::dhyper_opencl(n, x, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector phyper_opencl_cpp_export(
    int n,
    double q,
    double r,
    double b,
    double n1,
    bool verbose = false
) {
  return nmathopencl::phyper_opencl(n, q, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qhyper_opencl_cpp_export(
    int n,
    double p,
    double r,
    double b,
    double n1,
    bool verbose = false
) {
  return nmathopencl::qhyper_opencl(n, p, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rhyper_opencl_cpp_export(
    int n,
    double r,
    double b,
    double n1,
    bool verbose = false
) {
  return nmathopencl::rhyper_opencl(n, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qbinom_opencl_cpp_export(
    int n,
    double p,
    double size,
    double prob,
    bool verbose = false
) {
  return nmathopencl::qbinom_opencl(n, p, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qpois_opencl_cpp_export(
    int n,
    double p,
    double lambda,
    bool verbose = false
) {
  return nmathopencl::qpois_opencl(n, p, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dpois_raw_opencl_cpp_export(
    int n,
    double x,
    double lambda,
    bool verbose = false
) {
  return nmathopencl::dpois_raw_opencl(n, x, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dpois_opencl_cpp_export(
    int n,
    double x,
    double lambda,
    bool verbose = false
) {
  return nmathopencl::dpois_opencl(n, x, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector ppois_opencl_cpp_export(
    int n,
    double q,
    double lambda,
    bool verbose = false
) {
  return nmathopencl::ppois_opencl(n, q, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnbinom_mu_opencl_cpp_export(
    int n,
    double p,
    double size,
    double mu,
    bool verbose = false
) {
  return nmathopencl::qnbinom_mu_opencl(n, p, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rpois_opencl_cpp_export(
    int n,
    double lambda,
    bool verbose = false
) {
  return nmathopencl::rpois_opencl(n, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnbinom_mu_opencl_cpp_export(
    int n,
    double size,
    double mu,
    bool verbose = false
) {
  return nmathopencl::rnbinom_mu_opencl(n, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dweibull_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::dweibull_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pweibull_opencl_cpp_export(
    int n,
    double q,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::pweibull_opencl(n, q, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qweibull_opencl_cpp_export(
    int n,
    double p,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::qweibull_opencl(n, p, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rweibull_opencl_cpp_export(
    int n,
    double shape,
    double scale,
    bool verbose = false
) {
  return nmathopencl::rweibull_opencl(n, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dlogis_opencl_cpp_export(
    int n,
    double x,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::dlogis_opencl(n, x, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector plogis_opencl_cpp_export(
    int n,
    double q,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::plogis_opencl(n, q, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qlogis_opencl_cpp_export(
    int n,
    double p,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::qlogis_opencl(n, p, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rlogis_opencl_cpp_export(
    int n,
    double location,
    double scale,
    bool verbose = false
) {
  return nmathopencl::rlogis_opencl(n, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::pnchisq_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnchisq_opencl_cpp_export(
    int n,
    double p,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::qnchisq_opencl(n, p, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnf_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::pnf_opencl(n, x, df1, df2, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnf_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::dnf_opencl(n, x, df1, df2, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnf_opencl_cpp_export(
    int n,
    double p,
    double df1,
    double df2,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::qnf_opencl(n, p, df1, df2, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::pnbeta_opencl(n, x, a, b, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnbeta_opencl_cpp_export(
    int n,
    double p,
    double a,
    double b,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::qnbeta_opencl(n, p, a, b, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::dnbeta_opencl(n, x, a, b, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnt_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::dnt_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnt_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::pnt_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnt_opencl_cpp_export(
    int n,
    double p,
    double df,
    double ncp,
    bool verbose = false
) {
  return nmathopencl::qnt_opencl(n, p, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector ptukey_opencl_cpp_export(
    int n,
    double q,
    double nmeans,
    double df,
    double nranges,
    bool verbose = false
) {
  return nmathopencl::ptukey_opencl(n, q, nmeans, df, nranges, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qtukey_opencl_cpp_export(
    int n,
    double p,
    double nmeans,
    double df,
    double nranges,
    bool verbose = false
) {
  return nmathopencl::qtukey_opencl(n, p, nmeans, df, nranges, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dwilcox_opencl_cpp_export(
    int n,
    double x,
    double m,
    double n2,
    bool verbose = false
) {
  return nmathopencl::dwilcox_opencl(n, x, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pwilcox_opencl_cpp_export(
    int n,
    double q,
    double m,
    double n2,
    bool verbose = false
) {
  return nmathopencl::pwilcox_opencl(n, q, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qwilcox_opencl_cpp_export(
    int n,
    double p,
    double m,
    double n2,
    bool verbose = false
) {
  return nmathopencl::qwilcox_opencl(n, p, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dsignrank_opencl_cpp_export(
    int n,
    double x,
    double nsize,
    bool verbose = false
) {
  return nmathopencl::dsignrank_opencl(n, x, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector psignrank_opencl_cpp_export(
    int n,
    double q,
    double nsize,
    bool verbose = false
) {
  return nmathopencl::psignrank_opencl(n, q, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qsignrank_opencl_cpp_export(
    int n,
    double p,
    double nsize,
    bool verbose = false
) {
  return nmathopencl::qsignrank_opencl(n, p, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rsignrank_opencl_cpp_export(
    int n,
    double nsize,
    bool verbose = false
) {
  return nmathopencl::rsignrank_opencl(n, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector gammafn_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::gammafn_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgammafn_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::lgammafn_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgammafn_sign_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::lgammafn_sign_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dpsifn_opencl_cpp_export(
    int n,
    double x,
    double n_deriv,
    double kode,
    double m,
    bool verbose = false
) {
  return nmathopencl::dpsifn_opencl(n, x, n_deriv, kode, m, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector psigamma_opencl_cpp_export(
    int n,
    double x,
    double deriv,
    bool verbose = false
) {
  return nmathopencl::psigamma_opencl(n, x, deriv, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector digamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::digamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector trigamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::trigamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector tetragamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::tetragamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pentagamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::pentagamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector beta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::beta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lbeta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return nmathopencl::lbeta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector choose_opencl_cpp_export(
    int n,
    double n_val,
    double k,
    bool verbose = false
) {
  return nmathopencl::choose_opencl(n, n_val, k, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lchoose_opencl_cpp_export(
    int n,
    double n_val,
    double k,
    bool verbose = false
) {
  return nmathopencl::lchoose_opencl(n, n_val, k, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_i_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo_scaled,
    bool verbose = false
) {
  return nmathopencl::bessel_i_opencl(n, x, nu, expo_scaled, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_j_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return nmathopencl::bessel_j_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_k_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo_scaled,
    bool verbose = false
) {
  return nmathopencl::bessel_k_opencl(n, x, nu, expo_scaled, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_y_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return nmathopencl::bessel_y_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_i_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo,
    bool verbose = false
) {
  return nmathopencl::bessel_i_ex_opencl(n, x, nu, expo, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_j_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return nmathopencl::bessel_j_ex_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_k_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo,
    bool verbose = false
) {
  return nmathopencl::bessel_k_ex_opencl(n, x, nu, expo, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_y_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return nmathopencl::bessel_y_ex_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector imax2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::imax2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector imin2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::imin2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fmax2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::fmax2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fmin2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::fmin2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector sign_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::sign_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fprec_opencl_cpp_export(
    int n,
    double x,
    double digits,
    bool verbose = false
) {
  return nmathopencl::fprec_opencl(n, x, digits, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fround_opencl_cpp_export(
    int n,
    double x,
    double digits,
    bool verbose = false
) {
  return nmathopencl::fround_opencl(n, x, digits, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fsign_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return nmathopencl::fsign_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector ftrunc_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return nmathopencl::ftrunc_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_check_user_interrupt_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return nmathopencl::r_check_user_interrupt_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_check_stack_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return nmathopencl::r_check_stack_opencl(n, verbose);
}

// [[Rcpp::export]]
std::string load_kernel_source_wrapper_cpp_export(
    const std::string& relative_path,
    const std::string& package = "nmathopencl"
) {
  return load_kernel_source_wrapper(relative_path, package);
}

// [[Rcpp::export]]
std::string load_kernel_library_wrapper_cpp_export(
    const std::string& subdir,
    const std::string& package = "nmathopencl",
    bool verbose = false
) {
  return load_kernel_library_wrapper(subdir, package, verbose);
}

// [[Rcpp::export]]
bool has_opencl_cpp_export() {
  return has_opencl();
}

// [[Rcpp::export]]
int get_opencl_core_count_cpp_export() {
  return get_opencl_core_count();
}

// [[Rcpp::export]]
Rcpp::CharacterVector gpu_names_cpp_export() {
  return gpu_names();
}


