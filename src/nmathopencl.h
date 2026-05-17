/**
 * @file nmathopencl.h
 * @brief Core nmath/R distribution OpenCL kernel runners and Rcpp wrappers.
 *        These are nmathopencl's primary published product and have no
 *        glmbayes dependency.
 *
 * @namespace nmathopencl
 */

#ifndef NMATHOPENCL_H
#define NMATHOPENCL_H

#include <string>
#include <vector>
#include <Rcpp.h>

// =============================================================================
// nmathopencl namespace
// Core nmath/R distribution kernel runners and wrappers.
// These are nmathopencl's primary published product and have no glmbayes
// dependency.
// =============================================================================
namespace nmathopencl {

// -----------------------------------------------------------------------------
// Simple nmath function runner/wrapper (dnorm)
// -----------------------------------------------------------------------------
void dnorm_kernel_runner(
    const std::string&         kernel_source,
    const char*                kernel_name,
    const std::vector<double>& x_flat,
    double                     mu,
    double                     sigma,
    int                        give_log,
    std::vector<double>&       out_flat
);

Rcpp::NumericVector dnorm_opencl(
    const Rcpp::NumericVector& x,
    double                     mu,
    double                     sigma,
    bool                       give_log = false,
    bool                       verbose  = false
);

void runif_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               a,
    double               b,
    std::vector<double>& out_flat
);

void rnorm_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               mu,
    double               sigma,
    std::vector<double>& out_flat
);

void rexp_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n,
    double               scale,
    std::vector<double>& out_flat
);

void rwilcox_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               m,
    double               n2,
    std::vector<double>& out_flat
);

void rbinom_kernel_runner(
    const std::string&   kernel_source,
    const char*          kernel_name,
    int                  n_out,
    double               size,
    double               prob,
    std::vector<double>& out_flat
);


Rcpp::NumericVector runif_opencl(
    int    n,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector rnorm_opencl(
    int    n,
    double mu,
    double sigma,
    bool   verbose = false
);

Rcpp::NumericVector rexp_opencl(
    int    n,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector rwilcox_opencl(
    int    n_out,
    double m,
    double n2,
    bool   verbose = false
);

Rcpp::NumericVector rbinom_opencl(
    int    n_out,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector r_pow_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector r_pow_di_opencl(
    int    n_out,
    double x,
    int    n_exp,
    bool   verbose = false
);

Rcpp::NumericVector log1pmx_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector log1pexp_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector log1mexp_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector lgamma1p_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector pow1p_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector logspace_add_opencl(
    int    n_out,
    double logx,
    double logy,
    bool   verbose = false
);

Rcpp::NumericVector logspace_sub_opencl(
    int    n_out,
    double logx,
    double logy,
    bool   verbose = false
);

Rcpp::NumericVector logspace_sum_opencl(
    int    n_out,
    double logx,
    double logy,
    bool   verbose = false
);

Rcpp::NumericVector norm_rand_opencl(
    int  n_out,
    bool verbose = false
);

Rcpp::NumericVector unif_rand_opencl(
    int  n_out,
    bool verbose = false
);

Rcpp::NumericVector r_unif_index_opencl(
    int    n_out,
    double dn,
    bool   verbose = false
);

Rcpp::NumericVector exp_rand_opencl(
    int  n_out,
    bool verbose = false
);

Rcpp::NumericVector pnorm_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& mean,
    const Rcpp::NumericVector& sd,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int    opencl_parallel_code,
    bool   verbose = false
);

Rcpp::NumericVector qnorm_opencl(
    int    n_out,
    double p,
    double mu,
    double sigma,
    bool   verbose = false
);

Rcpp::NumericVector dunif_opencl(
    int    n_out,
    double x,
    double min,
    double max,
    bool   verbose = false
);

Rcpp::NumericVector punif_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& min,
    const Rcpp::NumericVector& max,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qunif_opencl(
    int    n_out,
    double p,
    double min,
    double max,
    bool   verbose = false
);

Rcpp::NumericVector dgamma_opencl(
    int    n_out,
    double x,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector pgamma_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qgamma_opencl(
    int    n_out,
    double p,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector rgamma_opencl(
    int    n_out,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector dbeta_opencl(
    int    n_out,
    double x,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector pbeta_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape1,
    const Rcpp::NumericVector& shape2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qbeta_opencl(
    int    n_out,
    double p,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector rbeta_opencl(
    int    n_out,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector dlnorm_opencl(
    int    n_out,
    double x,
    double meanlog,
    double sdlog,
    bool   verbose = false
);

Rcpp::NumericVector plnorm_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& meanlog,
    const Rcpp::NumericVector& sdlog,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qlnorm_opencl(
    int    n_out,
    double p,
    double meanlog,
    double sdlog,
    bool   verbose = false
);

Rcpp::NumericVector rlnorm_opencl(
    int    n_out,
    double meanlog,
    double sdlog,
    bool   verbose = false
);

Rcpp::NumericVector dchisq_opencl(
    int    n_out,
    double x,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector pchisq_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qchisq_opencl(
    int    n_out,
    double p,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector rchisq_opencl(
    int    n_out,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector dnchisq_opencl(
    int    n_out,
    double x,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector rnchisq_opencl(
    int    n_out,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector df_opencl(
    int    n_out,
    double x,
    double df1,
    double df2,
    bool   verbose = false
);

Rcpp::NumericVector pf_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df1,
    const Rcpp::NumericVector& df2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qf_opencl(
    int    n_out,
    double p,
    double df1,
    double df2,
    bool   verbose = false
);

Rcpp::NumericVector rf_opencl(
    int    n_out,
    double df1,
    double df2,
    bool   verbose = false
);

Rcpp::NumericVector dt_opencl(
    int    n_out,
    double x,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector pt_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qt_opencl(
    int    n_out,
    double p,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector rt_opencl(
    int    n_out,
    double df,
    bool   verbose = false
);

Rcpp::NumericVector qbinom_opencl(
    int    n_out,
    double p,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector dbinom_raw_opencl(
    int    n_out,
    double x,
    double n_size,
    double prob,
    double qprob,
    bool   verbose = false
);

Rcpp::NumericVector dbinom_opencl(
    int    n_out,
    double x,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector pbinom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector dnbinom_opencl(
    int    n_out,
    double x,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector pnbinom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qnbinom_opencl(
    int    n_out,
    double p,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector rnbinom_opencl(
    int    n_out,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector dnbinom_mu_opencl(
    int    n_out,
    double x,
    double size,
    double mu,
    bool   verbose = false
);

Rcpp::NumericVector pnbinom_mu_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& mu,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qpois_opencl(
    int    n_out,
    double p,
    double lambda,
    bool   verbose = false
);

Rcpp::NumericVector dpois_raw_opencl(
    int    n_out,
    double x,
    double lambda,
    bool   verbose = false
);

Rcpp::NumericVector dpois_opencl(
    int    n_out,
    double x,
    double lambda,
    bool   verbose = false
);

Rcpp::NumericVector ppois_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& lambda,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qnbinom_mu_opencl(
    int    n_out,
    double p,
    double size,
    double mu,
    bool   verbose = false
);

Rcpp::NumericVector rpois_opencl(
    int    n_out,
    double lambda,
    bool   verbose = false
);

Rcpp::NumericVector rnbinom_mu_opencl(
    int    n_out,
    double size,
    double mu,
    bool   verbose = false
);

Rcpp::NumericVector rmultinom_opencl(
    int    n_out,
    double size,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector dcauchy_opencl(
    int    n_out,
    double x,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector pcauchy_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qcauchy_opencl(
    int    n_out,
    double p,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector rcauchy_opencl(
    int    n_out,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector dexp_opencl(
    int    n_out,
    double x,
    double rate,
    bool   verbose = false
);

Rcpp::NumericVector pexp_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& rate,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qexp_opencl(
    int    n_out,
    double p,
    double rate,
    bool   verbose = false
);

Rcpp::NumericVector dgeom_opencl(
    int    n_out,
    double x,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector pgeom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qgeom_opencl(
    int    n_out,
    double p,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector rgeom_opencl(
    int    n_out,
    double prob,
    bool   verbose = false
);

Rcpp::NumericVector dhyper_opencl(
    int    n_out,
    double x,
    double r,
    double b,
    double n,
    bool   verbose = false
);

Rcpp::NumericVector phyper_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n_black,
    const Rcpp::NumericVector& k,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qhyper_opencl(
    int    n_out,
    double p,
    double r,
    double b,
    double n,
    bool   verbose = false
);

Rcpp::NumericVector rhyper_opencl(
    int    n_out,
    double r,
    double b,
    double n,
    bool   verbose = false
);

Rcpp::NumericVector dweibull_opencl(
    int    n_out,
    double x,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector pweibull_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qweibull_opencl(
    int    n_out,
    double p,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector rweibull_opencl(
    int    n_out,
    double shape,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector dlogis_opencl(
    int    n_out,
    double x,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector plogis_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qlogis_opencl(
    int    n_out,
    double p,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector rlogis_opencl(
    int    n_out,
    double location,
    double scale,
    bool   verbose = false
);

Rcpp::NumericVector dnbeta_opencl(
    int    n_out,
    double x,
    double a,
    double b,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector pnchisq_opencl(
    int    n_out,
    double x,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector qnchisq_opencl(
    int    n_out,
    double p,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector dnf_opencl(
    int    n_out,
    double x,
    double df1,
    double df2,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector qnf_opencl(
    int    n_out,
    double p,
    double df1,
    double df2,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector qnbeta_opencl(
    int    n_out,
    double p,
    double a,
    double b,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector dnt_opencl(
    int    n_out,
    double x,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector ptukey_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& nmeans,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& nranges,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qtukey_opencl(
    int    n_out,
    double p,
    double nmeans,
    double df,
    double nranges,
    bool   verbose = false
);

Rcpp::NumericVector dwilcox_opencl(
    int    n_out,
    double x,
    double m,
    double n2,
    bool   verbose = false
);

Rcpp::NumericVector pwilcox_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n2,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qwilcox_opencl(
    int    n_out,
    double p,
    double m,
    double n2,
    bool   verbose = false
);

Rcpp::NumericVector dsignrank_opencl(
    int    n_out,
    double x,
    double nsize,
    bool   verbose = false
);

Rcpp::NumericVector psignrank_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& nsize,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose = false
);

Rcpp::NumericVector qsignrank_opencl(
    int    n_out,
    double p,
    double nsize,
    bool   verbose = false
);

Rcpp::NumericVector rsignrank_opencl(
    int    n_out,
    double nsize,
    bool   verbose = false
);

Rcpp::NumericVector qnt_opencl(
    int    n_out,
    double p,
    double df,
    double ncp,
    bool   verbose = false
);

Rcpp::NumericVector gammafn_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector lgammafn_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector lgammafn_sign_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector dpsifn_opencl(
    int    n_out,
    double x,
    double n_deriv,
    double kode,
    double m,
    bool   verbose = false
);

Rcpp::NumericVector psigamma_opencl(
    int    n_out,
    double x,
    double deriv,
    bool   verbose = false
);

Rcpp::NumericVector digamma_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector trigamma_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector tetragamma_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector pentagamma_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector beta_opencl(
    int    n_out,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector lbeta_opencl(
    int    n_out,
    double a,
    double b,
    bool   verbose = false
);

Rcpp::NumericVector choose_opencl(
    int    n_out,
    double n_val,
    double k,
    bool   verbose = false
);

Rcpp::NumericVector lchoose_opencl(
    int    n_out,
    double n_val,
    double k,
    bool   verbose = false
);

Rcpp::NumericVector bessel_i_opencl(
    int    n_out,
    double x,
    double nu,
    double expo_scaled,
    bool   verbose = false
);

Rcpp::NumericVector bessel_j_opencl(
    int    n_out,
    double x,
    double nu,
    bool   verbose = false
);

Rcpp::NumericVector bessel_k_opencl(
    int    n_out,
    double x,
    double nu,
    double expo_scaled,
    bool   verbose = false
);

Rcpp::NumericVector bessel_y_opencl(
    int    n_out,
    double x,
    double nu,
    bool   verbose = false
);

Rcpp::NumericVector bessel_i_ex_opencl(
    int    n_out,
    double x,
    double nu,
    double expo,
    bool   verbose = false
);

Rcpp::NumericVector bessel_j_ex_opencl(
    int    n_out,
    double x,
    double nu,
    bool   verbose = false
);

Rcpp::NumericVector bessel_k_ex_opencl(
    int    n_out,
    double x,
    double nu,
    double expo,
    bool   verbose = false
);

Rcpp::NumericVector bessel_y_ex_opencl(
    int    n_out,
    double x,
    double nu,
    bool   verbose = false
);

Rcpp::NumericVector imax2_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector imin2_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector fmax2_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector fmin2_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector sign_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector fprec_opencl(
    int    n_out,
    double x,
    double digits,
    bool   verbose = false
);

Rcpp::NumericVector fround_opencl(
    int    n_out,
    double x,
    double digits,
    bool   verbose = false
);

Rcpp::NumericVector fsign_opencl(
    int    n_out,
    double x,
    double y,
    bool   verbose = false
);

Rcpp::NumericVector ftrunc_opencl(
    int    n_out,
    double x,
    bool   verbose = false
);

Rcpp::NumericVector r_check_user_interrupt_opencl(
    int  n_out,
    bool verbose = false
);

Rcpp::NumericVector r_check_stack_opencl(
    int  n_out,
    bool verbose = false
);

} // namespace nmathopencl

#endif
