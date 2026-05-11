#include "RcppArmadillo.h"
#include "Envelopefuncs.h"
#include "openclPort.h"
#include "opencl.h"
#include "simfuncs.h"

using namespace openclPort;
using namespace glmbayes::env;
using namespace glmbayes::sim;


// -----------------------------------------------------------------------------
// Wrapper organization mirrors R/rcpp_wrappers.R:
//   Tier 1: Core Simulation   - Main sampling entry points
//   Tier 2: Envelope          - Build/eval; used by rNormalGLM
//   Tier 3: Indep NG std      - Split workflow samplers
//   Tier 4: Model Utilities   - Standardization
//   Tier 5: OpenCL/GPU        - Kernel loading, diagnostics
//   Phased out: rss_face_at_disp, UB2 (no R wrappers)
// -----------------------------------------------------------------------------


// =============================================================================
// Tier 1: Core Simulation
// Callers: rNormal_reg, rNormalGamma_reg, rindepNormalGamma_reg, rGamma_reg
// User:    All users - primary paths via rglmb, rlmb, glmb, pfamily
// =============================================================================

// [[Rcpp::export]]
Rcpp::List rNormalGLM_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& offset,
    const Rcpp::NumericVector& wt,
    double dispersion,
    const Rcpp::Function& f2,
    const Rcpp::Function& f3,
    const Rcpp::NumericVector& start,
    const std::string& family = "binomial",
    const std::string& link   = "logit",
    int Gridtype = 2,
    int n_envopt = -1,
    bool use_parallel = true,
    bool use_opencl = false,
    bool verbose = false
) {
  return rNormalGLM(
    n, y, x, mu, P, offset, wt,
    dispersion,
    f2, f3, start,
    family, link, Gridtype,
    n_envopt, use_parallel, use_opencl, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List rNormalReg_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& offset,
    const Rcpp::NumericVector& wt,
    double dispersion,
    const Rcpp::Function& f2,
    const Rcpp::Function& f3,
    const Rcpp::NumericVector& start,
    const std::string& family = "gaussian",
    const std::string& link   = "identity",
    int Gridtype = 2
) {
  return rNormalReg(
    n, y, x, mu, P, offset, wt,
    dispersion, f2, f3, start,
    family, link, Gridtype
  );
}

// [[Rcpp::export]]
Rcpp::List rIndepNormalGammaReg_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& offset,
    const Rcpp::NumericVector& wt,
    double shape,
    double rate,
    double max_disp_perc,
    Rcpp::Nullable<Rcpp::NumericVector> disp_lower,
    Rcpp::Nullable<Rcpp::NumericVector> disp_upper,
    int Gridtype,
    int n_envopt,
    bool use_parallel,
    bool use_opencl,
    bool verbose,
    bool progbar
) {
  return rIndepNormalGammaReg(
    n,
    y,
    x,
    mu,
    P,
    offset,
    wt,
    shape,
    rate,
    max_disp_perc,
    disp_lower,
    disp_upper,
    Gridtype,
    n_envopt,
    use_parallel,
    use_opencl,
    verbose,
    progbar
  );
}

// [[Rcpp::export]]
Rcpp::List rNormalGammaReg_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& offset,
    const Rcpp::NumericVector& wt,
    double shape,
    double rate,
    Rcpp::Nullable<double> max_disp_perc,
    Rcpp::Nullable<double> disp_lower,
    Rcpp::Nullable<double> disp_upper,
    bool verbose = false
) {
  return glmbayes::sim::rNormalGammaReg(
    n,
    y,
    x,
    mu,
    P,
    offset,
    wt,
    shape,
    rate,
    max_disp_perc,
    disp_lower,
    disp_upper,
    verbose
  );
}

// [[Rcpp::export]]
Rcpp::List rGammaGaussian_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& beta,
    const Rcpp::NumericVector& wt,
    const Rcpp::NumericVector& alpha,
    double shape,
    double rate,
    Rcpp::Nullable<double> disp_lower = R_NilValue,
    Rcpp::Nullable<double> disp_upper = R_NilValue,
    bool verbose = false
) {
  return glmbayes::sim::rGammaGaussian(
    n, y, x, beta, wt, alpha,
    shape, rate,
    disp_lower, disp_upper,
    verbose
  );
}

// [[Rcpp::export]]
Rcpp::List rGammaGamma_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& beta,
    const Rcpp::NumericVector& wt,
    const Rcpp::NumericVector& alpha,
    double shape,
    double rate,
    double max_disp_perc,
    Rcpp::Nullable<double> disp_lower = R_NilValue,
    Rcpp::Nullable<double> disp_upper = R_NilValue,
    bool verbose = false
) {
  return glmbayes::sim::rGammaGamma(
    n, y, x, beta, wt, alpha,
    shape, rate, max_disp_perc,
    disp_lower, disp_upper,
    verbose
  );
}


// =============================================================================
// Tier 2: Envelope & Standardization
// Callers: EnvelopeSize, EnvelopeBuild, EnvelopeEval, EnvelopeDispersionBuild,
//          EnvelopeOrchestrator, rNormalGLM_std; EnvelopeSet_* are internal
// User:    Advanced users - understanding algorithm, custom envelope workflows
// =============================================================================

// [[Rcpp::export]]
Rcpp::List rNormalGLM_std_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    const Rcpp::Function& f2,
    const Rcpp::List& Envelope,
    const Rcpp::CharacterVector& family,
    const Rcpp::CharacterVector& link,
    int progbar = 1,
    bool verbose = false
) {
  return rNormalGLM_std(
    n, y, x, mu, P, alpha, wt,
    f2, Envelope, family, link,
    progbar, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeSize_cpp_export(
    const arma::vec& a,
    const Rcpp::NumericMatrix& G1,
    int Gridtype,
    int n,
    int n_envopt,
    bool use_opencl,
    bool verbose
) {
  return glmbayes::env::EnvelopeSize(
    a, G1, Gridtype, n, n_envopt, use_opencl, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeBuild_cpp_export(
    Rcpp::NumericVector bStar,
    Rcpp::NumericMatrix A,
    Rcpp::NumericVector y,
    Rcpp::NumericMatrix x,
    Rcpp::NumericMatrix mu,
    Rcpp::NumericMatrix P,
    Rcpp::NumericVector alpha,
    Rcpp::NumericVector wt,
    std::string family,
    std::string link,
    int Gridtype,
    int n,
    int n_envopt,
    bool sortgrid,
    bool use_opencl,
    bool verbose
) {
  return glmbayes::env::EnvelopeBuild(
    bStar, A, y, x, mu, P, alpha, wt,
    family, link, Gridtype, n, n_envopt,
    sortgrid, use_opencl, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeBuild_Ind_Normal_Gamma_cpp_export(
    const Rcpp::NumericVector& bStar,
    const Rcpp::NumericMatrix& A,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    const std::string& family = "binomial",
    const std::string& link   = "logit",
    int Gridtype              = 2,
    int n                     = 1,
    int n_envopt              = -1,
    bool sortgrid             = false,
    bool use_opencl           = false,
    bool verbose              = false
) {
  return EnvelopeBuild_Ind_Normal_Gamma(
    bStar, A, y, x, mu, P, alpha, wt,
    family, link,
    Gridtype, n, n_envopt,
    sortgrid, use_opencl, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeEval_cpp_export(
    const Rcpp::NumericMatrix& G4,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    const std::string& family,
    const std::string& link,
    bool use_opencl = false,
    bool verbose = false
) {
  return EnvelopeEval(
    G4, y, x, mu, P, alpha, wt,
    family, link,
    use_opencl, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeDispersionBuild_cpp_export(
    const Rcpp::List& Env,
    double Shape,
    double Rate,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& alpha,
    int n_obs,
    double RSS_post,
    double RSS_ML,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericVector& wt,
    double max_disp_perc = 0.99,
    Rcpp::Nullable<double> disp_lower = R_NilValue,
    Rcpp::Nullable<double> disp_upper = R_NilValue,
    bool verbose = false,
    bool use_parallel = true
) {
  return EnvelopeDispersionBuild(
    Env,
    Shape,
    Rate,
    P,
    y,
    x,
    alpha,
    n_obs,
    RSS_post,
    RSS_ML,
    mu,
    wt,
    max_disp_perc,
    disp_lower,
    disp_upper,
    verbose,
    use_parallel
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeOrchestrator_cpp_export(
    const Rcpp::NumericVector& bstar2,
    const Rcpp::NumericMatrix& A,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x2,
    const Rcpp::NumericMatrix& mu2,
    const Rcpp::NumericMatrix& P2,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    int n,
    int Gridtype,
    Rcpp::Nullable<int> n_envopt,
    double shape,
    double rate,
    double RSS_Post2,
    double RSS_ML,
    double max_disp_perc,
    Rcpp::Nullable<double> disp_lower,
    Rcpp::Nullable<double> disp_upper,
    bool use_parallel,
    bool use_opencl,
    bool verbose
) {
  return EnvelopeOrchestrator(
    bstar2,
    A,
    y,
    x2,
    mu2,
    P2,
    alpha,
    wt,
    n,
    Gridtype,
    n_envopt,
    shape,
    rate,
    RSS_Post2,
    RSS_ML,
    max_disp_perc,
    disp_lower,
    disp_upper,
    use_parallel,
    use_opencl,
    verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeCentering_cpp_export(
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& offset,
    const Rcpp::NumericVector& wt,
    double shape,
    double rate,
    int Gridtype = 2,
    bool verbose = false
) {
  return glmbayes::env::EnvelopeCentering(
    y, x, mu, P, offset, wt,
    shape, rate,
    Gridtype, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeSet_Grid_cpp_export(
    const Rcpp::NumericMatrix& GIndex,
    const Rcpp::NumericMatrix& cbars,
    const Rcpp::NumericMatrix& Lint
) {
  return EnvelopeSet_Grid(
    GIndex,
    cbars,
    Lint
  );
}

// [[Rcpp::export]]
Rcpp::List EnvelopeSet_LogP_cpp_export(
    const Rcpp::NumericMatrix& logP,
    const Rcpp::NumericVector& NegLL,
    const Rcpp::NumericMatrix& cbars,
    const Rcpp::NumericMatrix& G3
) {
  return EnvelopeSet_LogP(
    logP,
    NegLL,
    cbars,
    G3
  );
}


// =============================================================================
// Tier 3: Standardized Samplers (Indep Normal-Gamma)
// Callers: C++ only (rIndepNormalGammaReg); R wrappers for custom split workflow
// User:    Advanced / developers - after EnvelopeOrchestrator, sample separately
// =============================================================================

// [[Rcpp::export]]
Rcpp::List rIndepNormalGammaReg_std_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    const Rcpp::Function& f2,
    const Rcpp::List& Envelope,
    const Rcpp::List& gamma_list,
    const Rcpp::List& UB_list,
    const Rcpp::CharacterVector& family,
    const Rcpp::CharacterVector& link,
    bool progbar = true,
    bool verbose = false
) {
  return rIndepNormalGammaReg_std(
    n, y, x, mu, P, alpha, wt,
    f2, Envelope, gamma_list, UB_list,
    family, link, progbar, verbose
  );
}

// [[Rcpp::export]]
Rcpp::List rIndepNormalGammaReg_std_parallel_cpp_export(
    int n,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& mu,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    const Rcpp::Function& f2,
    const Rcpp::List& Envelope,
    const Rcpp::List& gamma_list,
    const Rcpp::List& UB_list,
    const Rcpp::CharacterVector& family,
    const Rcpp::CharacterVector& link,
    bool progbar = true,
    bool verbose = false
) {
  return rIndepNormalGammaReg_std_parallel(
    n, y, x, mu, P, alpha, wt,
    f2, Envelope, gamma_list, UB_list,
    family, link, progbar, verbose
  );
}


// =============================================================================
// Tier 4: Model Utilities
// Callers: glmb_Standardize_Model
// User:    Advanced users - model preparation, standardization
// =============================================================================

// [[Rcpp::export]]
Rcpp::List glmb_Standardize_Model_cpp_export(
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericMatrix& P,
    const Rcpp::NumericMatrix& bstar,
    const Rcpp::NumericMatrix& A1
) {
  return glmb_Standardize_Model(
    y, x, P, bstar, A1
  );
}


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
  return glmbayes::opencl::dnorm_opencl(x, mu, sigma, give_log, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector runif_opencl_cpp_export(
    int n,
    double a = 0.0,
    double b = 1.0,
    bool verbose = false
) {
  return glmbayes::opencl::runif_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnorm_opencl_cpp_export(
    int n,
    double mu = 0.0,
    double sigma = 1.0,
    bool verbose = false
) {
  return glmbayes::opencl::rnorm_opencl(n, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rexp_opencl_cpp_export(
    int n,
    double scale = 1.0,
    bool verbose = false
) {
  return glmbayes::opencl::rexp_opencl(n, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rwilcox_opencl_cpp_export(
    int n,
    double m,
    double n2,
    bool verbose = false
) {
  return glmbayes::opencl::rwilcox_opencl(n, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rbinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::rbinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_pow_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::r_pow_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_pow_di_opencl_cpp_export(
    int n,
    double x,
    int n_exp,
    bool verbose = false
) {
  return glmbayes::opencl::r_pow_di_opencl(n, x, n_exp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1pmx_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::log1pmx_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1pexp_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::log1pexp_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector log1mexp_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::log1mexp_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgamma1p_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::lgamma1p_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pow1p_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::pow1p_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_add_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return glmbayes::opencl::logspace_add_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_sub_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return glmbayes::opencl::logspace_sub_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector logspace_sum_opencl_cpp_export(
    int n,
    double logx,
    double logy,
    bool verbose = false
) {
  return glmbayes::opencl::logspace_sum_opencl(n, logx, logy, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector norm_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return glmbayes::opencl::norm_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector unif_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return glmbayes::opencl::unif_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_unif_index_opencl_cpp_export(
    int n,
    double dn,
    bool verbose = false
) {
  return glmbayes::opencl::r_unif_index_opencl(n, dn, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector exp_rand_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return glmbayes::opencl::exp_rand_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnorm_opencl_cpp_export(
    int n,
    double x,
    double mu,
    double sigma,
    bool verbose = false
) {
  return glmbayes::opencl::pnorm_opencl(n, x, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnorm_opencl_cpp_export(
    int n,
    double p,
    double mu,
    double sigma,
    bool verbose = false
) {
  return glmbayes::opencl::qnorm_opencl(n, p, mu, sigma, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dunif_opencl_cpp_export(
    int n,
    double x,
    double min,
    double max,
    bool verbose = false
) {
  return glmbayes::opencl::dunif_opencl(n, x, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector punif_opencl_cpp_export(
    int n,
    double x,
    double min,
    double max,
    bool verbose = false
) {
  return glmbayes::opencl::punif_opencl(n, x, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qunif_opencl_cpp_export(
    int n,
    double p,
    double min,
    double max,
    bool verbose = false
) {
  return glmbayes::opencl::qunif_opencl(n, p, min, max, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dgamma_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::dgamma_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pgamma_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::pgamma_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qgamma_opencl_cpp_export(
    int n,
    double p,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::qgamma_opencl(n, p, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rgamma_opencl_cpp_export(
    int n,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::rgamma_opencl(n, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::dbeta_opencl(n, x, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pbeta_opencl_cpp_export(
    int n,
    double x,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::pbeta_opencl(n, x, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qbeta_opencl_cpp_export(
    int n,
    double p,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::qbeta_opencl(n, p, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rbeta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::rbeta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dlnorm_opencl_cpp_export(
    int n,
    double x,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return glmbayes::opencl::dlnorm_opencl(n, x, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector plnorm_opencl_cpp_export(
    int n,
    double q,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return glmbayes::opencl::plnorm_opencl(n, q, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qlnorm_opencl_cpp_export(
    int n,
    double p,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return glmbayes::opencl::qlnorm_opencl(n, p, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rlnorm_opencl_cpp_export(
    int n,
    double meanlog,
    double sdlog,
    bool verbose = false
) {
  return glmbayes::opencl::rlnorm_opencl(n, meanlog, sdlog, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::dchisq_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::pchisq_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qchisq_opencl_cpp_export(
    int n,
    double p,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::qchisq_opencl(n, p, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rchisq_opencl_cpp_export(
    int n,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::rchisq_opencl(n, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::dnchisq_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnchisq_opencl_cpp_export(
    int n,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::rnchisq_opencl(n, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector df_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    bool verbose = false
) {
  return glmbayes::opencl::df_opencl(n, x, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pf_opencl_cpp_export(
    int n,
    double x,
    double df1,
    double df2,
    bool verbose = false
) {
  return glmbayes::opencl::pf_opencl(n, x, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qf_opencl_cpp_export(
    int n,
    double p,
    double df1,
    double df2,
    bool verbose = false
) {
  return glmbayes::opencl::qf_opencl(n, p, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rf_opencl_cpp_export(
    int n,
    double df1,
    double df2,
    bool verbose = false
) {
  return glmbayes::opencl::rf_opencl(n, df1, df2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dt_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::dt_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pt_opencl_cpp_export(
    int n,
    double x,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::pt_opencl(n, x, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qt_opencl_cpp_export(
    int n,
    double p,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::qt_opencl(n, p, df, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rt_opencl_cpp_export(
    int n,
    double df,
    bool verbose = false
) {
  return glmbayes::opencl::rt_opencl(n, df, verbose);
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
  return glmbayes::opencl::dbinom_raw_opencl(n, x, n_size, prob, qprob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dbinom_opencl_cpp_export(
    int n,
    double x,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::dbinom_opencl(n, x, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pbinom_opencl_cpp_export(
    int n,
    double q,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::pbinom_opencl(n, q, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnbinom_opencl_cpp_export(
    int n,
    double x,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::dnbinom_opencl(n, x, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnbinom_opencl_cpp_export(
    int n,
    double q,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::pnbinom_opencl(n, q, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnbinom_opencl_cpp_export(
    int n,
    double p,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::qnbinom_opencl(n, p, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnbinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::rnbinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnbinom_mu_opencl_cpp_export(
    int n,
    double x,
    double size,
    double mu,
    bool verbose = false
) {
  return glmbayes::opencl::dnbinom_mu_opencl(n, x, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnbinom_mu_opencl_cpp_export(
    int n,
    double q,
    double size,
    double mu,
    bool verbose = false
) {
  return glmbayes::opencl::pnbinom_mu_opencl(n, q, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rmultinom_opencl_cpp_export(
    int n,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::rmultinom_opencl(n, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dcauchy_opencl_cpp_export(
    int n,
    double x,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::dcauchy_opencl(n, x, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pcauchy_opencl_cpp_export(
    int n,
    double q,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::pcauchy_opencl(n, q, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qcauchy_opencl_cpp_export(
    int n,
    double p,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::qcauchy_opencl(n, p, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rcauchy_opencl_cpp_export(
    int n,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::rcauchy_opencl(n, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dexp_opencl_cpp_export(
    int n,
    double x,
    double rate,
    bool verbose = false
) {
  return glmbayes::opencl::dexp_opencl(n, x, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pexp_opencl_cpp_export(
    int n,
    double q,
    double rate,
    bool verbose = false
) {
  return glmbayes::opencl::pexp_opencl(n, q, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qexp_opencl_cpp_export(
    int n,
    double p,
    double rate,
    bool verbose = false
) {
  return glmbayes::opencl::qexp_opencl(n, p, rate, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dgeom_opencl_cpp_export(
    int n,
    double x,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::dgeom_opencl(n, x, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pgeom_opencl_cpp_export(
    int n,
    double q,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::pgeom_opencl(n, q, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qgeom_opencl_cpp_export(
    int n,
    double p,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::qgeom_opencl(n, p, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rgeom_opencl_cpp_export(
    int n,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::rgeom_opencl(n, prob, verbose);
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
  return glmbayes::opencl::dhyper_opencl(n, x, r, b, n1, verbose);
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
  return glmbayes::opencl::phyper_opencl(n, q, r, b, n1, verbose);
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
  return glmbayes::opencl::qhyper_opencl(n, p, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rhyper_opencl_cpp_export(
    int n,
    double r,
    double b,
    double n1,
    bool verbose = false
) {
  return glmbayes::opencl::rhyper_opencl(n, r, b, n1, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qbinom_opencl_cpp_export(
    int n,
    double p,
    double size,
    double prob,
    bool verbose = false
) {
  return glmbayes::opencl::qbinom_opencl(n, p, size, prob, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qpois_opencl_cpp_export(
    int n,
    double p,
    double lambda,
    bool verbose = false
) {
  return glmbayes::opencl::qpois_opencl(n, p, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dpois_raw_opencl_cpp_export(
    int n,
    double x,
    double lambda,
    bool verbose = false
) {
  return glmbayes::opencl::dpois_raw_opencl(n, x, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dpois_opencl_cpp_export(
    int n,
    double x,
    double lambda,
    bool verbose = false
) {
  return glmbayes::opencl::dpois_opencl(n, x, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector ppois_opencl_cpp_export(
    int n,
    double q,
    double lambda,
    bool verbose = false
) {
  return glmbayes::opencl::ppois_opencl(n, q, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnbinom_mu_opencl_cpp_export(
    int n,
    double p,
    double size,
    double mu,
    bool verbose = false
) {
  return glmbayes::opencl::qnbinom_mu_opencl(n, p, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rpois_opencl_cpp_export(
    int n,
    double lambda,
    bool verbose = false
) {
  return glmbayes::opencl::rpois_opencl(n, lambda, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rnbinom_mu_opencl_cpp_export(
    int n,
    double size,
    double mu,
    bool verbose = false
) {
  return glmbayes::opencl::rnbinom_mu_opencl(n, size, mu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dweibull_opencl_cpp_export(
    int n,
    double x,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::dweibull_opencl(n, x, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pweibull_opencl_cpp_export(
    int n,
    double q,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::pweibull_opencl(n, q, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qweibull_opencl_cpp_export(
    int n,
    double p,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::qweibull_opencl(n, p, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rweibull_opencl_cpp_export(
    int n,
    double shape,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::rweibull_opencl(n, shape, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dlogis_opencl_cpp_export(
    int n,
    double x,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::dlogis_opencl(n, x, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector plogis_opencl_cpp_export(
    int n,
    double q,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::plogis_opencl(n, q, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qlogis_opencl_cpp_export(
    int n,
    double p,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::qlogis_opencl(n, p, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rlogis_opencl_cpp_export(
    int n,
    double location,
    double scale,
    bool verbose = false
) {
  return glmbayes::opencl::rlogis_opencl(n, location, scale, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnchisq_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::pnchisq_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnchisq_opencl_cpp_export(
    int n,
    double p,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::qnchisq_opencl(n, p, df, ncp, verbose);
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
  return glmbayes::opencl::pnf_opencl(n, x, df1, df2, ncp, verbose);
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
  return glmbayes::opencl::dnf_opencl(n, x, df1, df2, ncp, verbose);
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
  return glmbayes::opencl::qnf_opencl(n, p, df1, df2, ncp, verbose);
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
  return glmbayes::opencl::pnbeta_opencl(n, x, a, b, ncp, verbose);
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
  return glmbayes::opencl::qnbeta_opencl(n, p, a, b, ncp, verbose);
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
  return glmbayes::opencl::dnbeta_opencl(n, x, a, b, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dnt_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::dnt_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pnt_opencl_cpp_export(
    int n,
    double x,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::pnt_opencl(n, x, df, ncp, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qnt_opencl_cpp_export(
    int n,
    double p,
    double df,
    double ncp,
    bool verbose = false
) {
  return glmbayes::opencl::qnt_opencl(n, p, df, ncp, verbose);
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
  return glmbayes::opencl::ptukey_opencl(n, q, nmeans, df, nranges, verbose);
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
  return glmbayes::opencl::qtukey_opencl(n, p, nmeans, df, nranges, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dwilcox_opencl_cpp_export(
    int n,
    double x,
    double m,
    double n2,
    bool verbose = false
) {
  return glmbayes::opencl::dwilcox_opencl(n, x, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pwilcox_opencl_cpp_export(
    int n,
    double q,
    double m,
    double n2,
    bool verbose = false
) {
  return glmbayes::opencl::pwilcox_opencl(n, q, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qwilcox_opencl_cpp_export(
    int n,
    double p,
    double m,
    double n2,
    bool verbose = false
) {
  return glmbayes::opencl::qwilcox_opencl(n, p, m, n2, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector dsignrank_opencl_cpp_export(
    int n,
    double x,
    double nsize,
    bool verbose = false
) {
  return glmbayes::opencl::dsignrank_opencl(n, x, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector psignrank_opencl_cpp_export(
    int n,
    double q,
    double nsize,
    bool verbose = false
) {
  return glmbayes::opencl::psignrank_opencl(n, q, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector qsignrank_opencl_cpp_export(
    int n,
    double p,
    double nsize,
    bool verbose = false
) {
  return glmbayes::opencl::qsignrank_opencl(n, p, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector rsignrank_opencl_cpp_export(
    int n,
    double nsize,
    bool verbose = false
) {
  return glmbayes::opencl::rsignrank_opencl(n, nsize, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector gammafn_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::gammafn_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgammafn_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::lgammafn_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lgammafn_sign_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::lgammafn_sign_opencl(n, x, verbose);
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
  return glmbayes::opencl::dpsifn_opencl(n, x, n_deriv, kode, m, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector psigamma_opencl_cpp_export(
    int n,
    double x,
    double deriv,
    bool verbose = false
) {
  return glmbayes::opencl::psigamma_opencl(n, x, deriv, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector digamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::digamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector trigamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::trigamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector tetragamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::tetragamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector pentagamma_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::pentagamma_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector beta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::beta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lbeta_opencl_cpp_export(
    int n,
    double a,
    double b,
    bool verbose = false
) {
  return glmbayes::opencl::lbeta_opencl(n, a, b, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector choose_opencl_cpp_export(
    int n,
    double n_val,
    double k,
    bool verbose = false
) {
  return glmbayes::opencl::choose_opencl(n, n_val, k, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector lchoose_opencl_cpp_export(
    int n,
    double n_val,
    double k,
    bool verbose = false
) {
  return glmbayes::opencl::lchoose_opencl(n, n_val, k, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_i_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo_scaled,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_i_opencl(n, x, nu, expo_scaled, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_j_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_j_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_k_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo_scaled,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_k_opencl(n, x, nu, expo_scaled, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_y_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_y_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_i_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_i_ex_opencl(n, x, nu, expo, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_j_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_j_ex_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_k_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    double expo,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_k_ex_opencl(n, x, nu, expo, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector bessel_y_ex_opencl_cpp_export(
    int n,
    double x,
    double nu,
    bool verbose = false
) {
  return glmbayes::opencl::bessel_y_ex_opencl(n, x, nu, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector imax2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::imax2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector imin2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::imin2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fmax2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::fmax2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fmin2_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::fmin2_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector sign_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::sign_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fprec_opencl_cpp_export(
    int n,
    double x,
    double digits,
    bool verbose = false
) {
  return glmbayes::opencl::fprec_opencl(n, x, digits, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fround_opencl_cpp_export(
    int n,
    double x,
    double digits,
    bool verbose = false
) {
  return glmbayes::opencl::fround_opencl(n, x, digits, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector fsign_opencl_cpp_export(
    int n,
    double x,
    double y,
    bool verbose = false
) {
  return glmbayes::opencl::fsign_opencl(n, x, y, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector ftrunc_opencl_cpp_export(
    int n,
    double x,
    bool verbose = false
) {
  return glmbayes::opencl::ftrunc_opencl(n, x, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_check_user_interrupt_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return glmbayes::opencl::r_check_user_interrupt_opencl(n, verbose);
}

// [[Rcpp::export]]
Rcpp::NumericVector r_check_stack_opencl_cpp_export(
    int n,
    bool verbose = false
) {
  return glmbayes::opencl::r_check_stack_opencl(n, verbose);
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


// =============================================================================
// Phased Out (no R wrappers; C++ exports commented out)
// - rss_face_at_disp, UB2: former RSS/UB2 minimization; active path uses
//   closed-form C++ bounds.
//
// To fully remove: delete this block, then (1) remove *.o from src/,
// (2) uninstall old glmbayes, (3) Rcpp::compileAttributes(),
// (4) devtools::document(), (5) devtools::install().
// =============================================================================

/*
// [[Rcpp::export]]
double rss_face_at_disp_cpp_export(
    double dispersion,
    const Rcpp::List& cache,
    const Rcpp::NumericVector& cbars_j,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt
) {
  return rss_face_at_disp(
    dispersion,
    cache,
    cbars_j,
    y,
    x,
    alpha,
    wt
  );
}

// [[Rcpp::export]]
double UB2_cpp_export(
    double dispersion,
    const Rcpp::List& cache,
    const Rcpp::NumericVector& cbars_j,
    const Rcpp::NumericVector& y,
    const Rcpp::NumericMatrix& x,
    const Rcpp::NumericVector& alpha,
    const Rcpp::NumericVector& wt,
    double rss_min_global
) {
  return UB2(
    dispersion,
    cache,
    cbars_j,
    y,
    x,
    alpha,
    wt,
    rss_min_global
  );
}
*/
