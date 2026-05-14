// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

/**
 * @file ex_glmbayes_Envelopefuncs.h
 * @brief Core envelope–construction routines for glmbayes.
 *
 * @namespace ex_glmbayes::env
 *
 * @section ImplementedIn
 *   - ex_glmbayes_EnvelopeSize.cpp
 *   - ex_glmbayes_EnvelopeEval.cpp
 *
 * @section UsedBy
 *   - ex_glmbayes_export_wrappers.cpp (Ex_EnvelopeSize, Ex_EnvelopeEval example exports)
 */

#ifndef EX_GLMBAYES_ENV_H
#define EX_GLMBAYES_ENV_H


// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;


namespace ex_glmbayes{

namespace env{
Rcpp::List EnvelopeSize(const arma::vec& a,
                        const Rcpp::NumericMatrix& G1,
                        int Gridtype   = 2,
                        int n          = 1000,
                        int n_envopt   = -1,
                        bool use_opencl = false,
                        bool verbose    = false);




Rcpp::List EnvelopeEval(const Rcpp::NumericMatrix& G4,   // grid (parameters × grid points)
                        const Rcpp::NumericVector& y,
                        const Rcpp::NumericMatrix& x,
                        const Rcpp::NumericMatrix& mu,
                        const Rcpp::NumericMatrix& P,
                        const Rcpp::NumericVector& alpha,
                        const Rcpp::NumericVector& wt,
                        const std::string& family,
                        const std::string& link,
                        bool use_opencl = false,
                        bool verbose = false);



} //env

}  //glmbayes




#endif
