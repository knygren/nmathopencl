// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

/**
 * @file Envelopefuncs.h
 * @brief Core envelope–construction routines for glmbayes.
 *
 * @namespace glmbayes::env
 *
 * @section ImplementedIn
 *   - EnvelopeSize.cpp
 *   - EnvelopeEval.cpp
 *   - EnvelopeSort.cpp
 *   - Set_Grid.cpp
 *   - Set_LogP.cpp
 *
 * @section UsedBy
 *   - export_wrappers.cpp (Ex_EnvelopeSize, Ex_EnvelopeEval example exports)
 */

#ifndef GLMBAYES_ENV_H
#define GLMBAYES_ENV_H


// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;


namespace glmbayes{

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



Rcpp::List EnvelopeSort_cpp(
    int l1,
    int l2,
    const Rcpp::NumericMatrix& GIndex,
    const Rcpp::NumericMatrix& G3,
    const Rcpp::NumericMatrix& cbars,
    const Rcpp::NumericMatrix& logU,   // l2 x l1 (or l2 x ncol); R also accepts vector
    const Rcpp::NumericMatrix& logrt,
    const Rcpp::NumericMatrix& loglt,
    const Rcpp::NumericMatrix& logP,   // l2 x 2 (or l2 x ncol)
    const Rcpp::NumericMatrix& LLconst,  // l2 x 1 (or l2 x ncol)
    const Rcpp::NumericVector& PLSD,
    const Rcpp::NumericVector& a1,
    double E_draws,
    const Rcpp::Nullable<Rcpp::NumericVector>& lg_prob_factor = R_NilValue,
    const Rcpp::Nullable<Rcpp::NumericVector>& UB2min        = R_NilValue
);



List EnvelopeSet_Grid(Rcpp::NumericMatrix GIndex,  Rcpp::NumericMatrix cbars, Rcpp::NumericMatrix Lint);
void EnvelopeSet_Grid_C2(Rcpp::NumericMatrix GIndex,  Rcpp::NumericMatrix cbars, Rcpp::NumericMatrix Lint,Rcpp::NumericMatrix Down,Rcpp::NumericMatrix Up,Rcpp::NumericMatrix lglt,Rcpp::NumericMatrix lgrt,Rcpp::NumericMatrix lgct,Rcpp::NumericMatrix logU,Rcpp::NumericMatrix logP);
void EnvelopeSet_Grid_C2_pointwise(Rcpp::NumericMatrix GIndex,  Rcpp::NumericMatrix cbars, Rcpp::NumericMatrix Lint,Rcpp::NumericMatrix Down,Rcpp::NumericMatrix Up,Rcpp::NumericMatrix lglt,Rcpp::NumericMatrix lgrt,Rcpp::NumericMatrix lgct,Rcpp::NumericMatrix logU,Rcpp::NumericMatrix logP);


List   EnvelopeSet_LogP(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3);


} //env

}  //glmbayes




NumericVector RSS(NumericVector y, NumericMatrix x,NumericMatrix b,NumericVector alpha,NumericVector wt);




// Rcpp::List Set_Grid_C(Rcpp::NumericMatrix GIndex,  Rcpp::NumericMatrix cbars, Rcpp::NumericMatrix Lint,Rcpp::NumericMatrix Down,Rcpp::NumericMatrix Up,Rcpp::NumericMatrix lglt,Rcpp::NumericMatrix lgrt,Rcpp::NumericMatrix lgct,Rcpp::NumericMatrix logU,Rcpp::NumericMatrix logP);


// Rcpp::List   setlogP_C(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3,NumericMatrix LLconst);
void setlogP_C2(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3,NumericMatrix LLconst);




double rss_face_at_disp(double dispersion,
                        Rcpp::List cache,
                        Rcpp::NumericVector cbars_j,
                        Rcpp::NumericVector y,
                        Rcpp::NumericMatrix x,
                        Rcpp::NumericVector alpha,
                        Rcpp::NumericVector wt);

double UB2(double dispersion,
           Rcpp::List cache,
           Rcpp::NumericVector cbars_j,
           Rcpp::NumericVector y,
           Rcpp::NumericMatrix x,
           Rcpp::NumericVector alpha,
           Rcpp::NumericVector wt,
           double rss_min_global);



#endif