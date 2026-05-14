#include "RcppArmadillo.h"
#include "ex_glmbayes_Envelopefuncs.h"
#include "ex_glmbayes_simfuncs.h"

using namespace ex_glmbayes::env;
using namespace ex_glmbayes::sim;


// -----------------------------------------------------------------------------
// Wrapper organization mirrors R/ex_glmbayes_rcpp_wrappers.R:
//   Tier 2: Envelope (Example) - EnvelopeSize, EnvelopeEval
//   Tier 4: Model Utilities    - glmb_Standardize_Model
// These wrappers exist solely to support the Ex_EnvelopeEval example.
// If the example is removed, this file can be deleted along with
// ex_glmbayes_rcpp_wrappers.R and ex_glmbayes.R.
// -----------------------------------------------------------------------------


// =============================================================================
// Tier 2: Envelope (Example Support)
// Callers: Ex_EnvelopeSize (via .EnvelopeSize_cpp), Ex_EnvelopeEval (via .EnvelopeEval_cpp)
// User:    Downstream packages building custom OpenCL kernels on nmath
// =============================================================================

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
  return ex_glmbayes::env::EnvelopeSize(
    a, G1, Gridtype, n, n_envopt, use_opencl, verbose
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
