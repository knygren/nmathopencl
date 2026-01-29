#include "RcppArmadillo.h"
#include "Envelopefuncs.h"

// No [[Rcpp::export]] — prevents RcppExports generation

extern "C" SEXP _glmbayes_EnvelopeSize(SEXP aSEXP,
                                      SEXP G1SEXP,
                                      SEXP GridtypeSEXP,
                                      SEXP nSEXP,
                                      SEXP n_envoptSEXP,
                                      SEXP use_openclSEXP,
                                      SEXP verboseSEXP)
{
  try {
    // Convert inputs
    arma::vec a = Rcpp::as<arma::vec>(aSEXP);
    Rcpp::NumericMatrix G1 = Rcpp::as<Rcpp::NumericMatrix>(G1SEXP);
    
    int Gridtype   = Rcpp::as<int>(GridtypeSEXP);
    int n          = Rcpp::as<int>(nSEXP);
    int n_envopt   = Rcpp::as<int>(n_envoptSEXP);
    bool use_opencl = Rcpp::as<bool>(use_openclSEXP);
    bool verbose    = Rcpp::as<bool>(verboseSEXP);
    
    // Call the implementation (namespaced or not)
    Rcpp::List out = EnvelopeSize(
      a, G1, Gridtype, n, n_envopt, use_opencl, verbose
    );
    // If you move it into a namespace, change to:
    // Rcpp::List out = envelope::EnvelopeSize(...);
    
    return out;
  }
  catch (std::exception &ex) {
    forward_exception_to_r(ex);
  }
  catch (...) {
    Rcpp::stop("Unknown C++ exception in _glmbayes_EnvelopeSize");
  }
  
  return R_NilValue; // never reached
}