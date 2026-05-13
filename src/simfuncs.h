// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

/**
 * @file simfuncs.h
 * @brief Simulation and posterior sampling routines for glmbayes.
 *
 * @namespace glmbayes::sim
 * @brief Core Normal, Normal–Gamma, and independent Normal–Gamma samplers.
 *
 * @section ImplementedIn
 *   These declarations are implemented in:
 *     - rNormalGLM.cpp       (rNormalGLM_std)
 *     - rIndepNormalGammaReg.cpp  (rIndepNormalGammaReg_std, rIndepNormalGammaReg_std_parallel)
 *     - glmb_Standardize_Model.cpp
 *
 * @section UsedBy
 *   These functions are consumed internally by remaining C++ samplers.
 *
 * @section Responsibilities
 *   Provides simulation kernels for:
 *     - Normal GLM standardized posterior draws
 *     - Independent Normal–Gamma regression (standard and parallel variants)
 *
 *   All routines:
 *     - assume validated inputs,
 *     - use Rcpp::List for structured return objects,
 *     - rely on envelope objects and f2/f3 functions for accept–reject sampling.
 */

// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#ifndef GLMBAYES_SIM_H
#define GLMBAYES_SIM_H


// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;


namespace glmbayes {

namespace sim {

Rcpp::List  rNormalGLM_std(int n,
                               NumericVector y,
                               NumericMatrix x,
                               NumericMatrix mu,
                               NumericMatrix P,
                               NumericVector alpha,
                               NumericVector wt,
                               Function f2,
                               Rcpp::List  Envelope,
                               Rcpp::CharacterVector   family,
                               Rcpp::CharacterVector   link, 
                               int progbar=1,
                               bool verbose = false                                 
                                 );


Rcpp::List  rIndepNormalGammaReg_std(int n,NumericVector y,NumericMatrix x,
                                          NumericMatrix mu, /// This is typically standardized to be a zero vector
                                          NumericMatrix P, /// Part of prior precision shifted to the likelihood
                                          NumericVector alpha,NumericVector wt,
                                          Function f2,Rcpp::List  Envelope,
                                          Rcpp::List  gamma_list,
                                          Rcpp::List  UB_list,
                                          Rcpp::CharacterVector   family,Rcpp::CharacterVector   link,
                                          bool progbar=true,
                                          bool verbose=false);

Rcpp::List rIndepNormalGammaReg_std_parallel(
    int n,
    Rcpp::NumericVector y,
    Rcpp::NumericMatrix x,
    Rcpp::NumericMatrix mu,   // typically standardized to be a zero vector
    Rcpp::NumericMatrix P,    // part of prior precision shifted to the likelihood
    Rcpp::NumericVector alpha,
    Rcpp::NumericVector wt,
    Rcpp::Function f2,        // kept for signature parity
    Rcpp::List Envelope,
    Rcpp::List gamma_list,
    Rcpp::List UB_list,
    Rcpp::CharacterVector family,
    Rcpp::CharacterVector link,
    bool progbar = true,
    bool verbose = false
);



Rcpp::List glmb_Standardize_Model(
    NumericVector y, 
    NumericMatrix x,   // Original design matrix (to be adjusted)
    NumericMatrix P,   // Prior Precision Matrix (to be adjusted)
    NumericMatrix bstar, // Posterior Mode from optimization (to be adjusted)
    NumericMatrix A1  // Precision for Log-Posterior at posterior mode (to be adjusted)
);


}
}

#endif