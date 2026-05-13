// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

/**
 * @file simfuncs.h
 * @brief Model standardization routine for glmbayes.
 *
 * @namespace glmbayes::sim
 *
 * @section ImplementedIn
 *   - glmb_Standardize_Model.cpp
 *
 * @section UsedBy
 *   Consumed by export_wrappers.cpp (glmb_Standardize_Model_cpp_export),
 *   which backs the Ex_glmb_Standardize_Model example.
 */

// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#ifndef GLMBAYES_SIM_H
#define GLMBAYES_SIM_H


// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;


namespace glmbayes {

namespace sim {

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