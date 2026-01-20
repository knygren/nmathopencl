// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;

List EnvelopeBuild_cpp(NumericVector bStar,
                     NumericMatrix A,
                     NumericVector y,
                     NumericMatrix x,
                     NumericMatrix mu,
                     NumericMatrix P,
                     NumericVector alpha,
                     NumericVector wt,
                     std::string family = "binomial",
                     std::string link   = "logit",
                     int Gridtype       = 2,
                     int n              = 1,
                     int n_envopt       = -1,   // NEW: effective sample size for EnvelopeOpt (defaults to n if -1)
                     bool sortgrid      = false,
                     bool use_opencl    = false, // Enables OpenCL acceleration during envelope construction
                     bool verbose       = false  // Enables diagnostic output
);


// Dispersion-aware envelope solver
arma::mat Inv_f3_with_disp(Rcpp::List cache,
                           double dispersion,
                           Rcpp::NumericMatrix cbars_small);


double rss_face_at_disp(double dispersion,
                        Rcpp::List cache,
                        Rcpp::NumericVector cbars_j,
                        Rcpp::NumericVector y,
                        Rcpp::NumericMatrix x,
                        Rcpp::NumericVector alpha,
                        Rcpp::NumericVector wt) ;
