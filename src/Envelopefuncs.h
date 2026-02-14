// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

using namespace Rcpp;

// Dependencies:


// 1) EnvelopeSize.cpp
// 2) EnvelopeBuild.cpp
// 3) EnvelopeEval.cpp
// 4) EnvelopeBuild_Ind_Normal_Gamma.cpp
// 5) EnvelopeDispersionBuild.cpp

namespace glmbayes{

namespace env{
Rcpp::List EnvelopeSize(const arma::vec& a,
                        const Rcpp::NumericMatrix& G1,
                        int Gridtype   = 2,
                        int n          = 1000,
                        int n_envopt   = -1,
                        bool use_opencl = false,
                        bool verbose    = false);



List EnvelopeBuild(NumericVector bStar,
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

List EnvelopeBuild_Ind_Normal_Gamma(NumericVector bStar,
                                    NumericMatrix A,
                                    NumericVector y, 
                                    NumericMatrix x,
                                    NumericMatrix mu,
                                    NumericMatrix P,
                                    NumericVector alpha,
                                    NumericVector wt,
                                    std::string family="binomial",
                                    std::string link="logit",
                                    int Gridtype=2, 
                                    int n=1,
                                    int n_envopt=-1,
                                    bool sortgrid=false,
                                    bool use_opencl    = false,
                                    bool verbose       = false);


List EnvelopeDispersionBuild(
    List Env,
    double Shape,
    double Rate,
    NumericMatrix P,
    NumericVector y,
    NumericMatrix x,
    NumericVector alpha,
    int n_obs,
    double RSS_post,
    double RSS_ML,
    NumericMatrix mu,         // ← new
    NumericVector wt,         // ← new
    double max_disp_perc ,
    Nullable<double> disp_lower ,
    Nullable<double> disp_upper ,
    bool verbose ,
    bool use_parallel    // ← add flag here
    
);


Rcpp::List EnvelopeOrchestrator(
    NumericVector bstar2,
    NumericMatrix A,
    NumericVector y,
    NumericMatrix x2,
    NumericMatrix mu2,
    NumericMatrix P2,
    NumericVector alpha,
    NumericVector wt,
    
    int n,
    int Gridtype,
    Nullable<int> n_envopt,
    
    double shape,
    double rate,
    double RSS_Post2,
    double RSS_ML,
    
    double max_disp_perc,
    Nullable<double> disp_lower,
    Nullable<double> disp_upper,
    
    bool use_parallel,
    bool use_opencl,
    bool verbose
);

Rcpp::List EnvelopeSort_cpp(
    int l1,
    int l2,
    const Rcpp::NumericMatrix& GIndex,
    const Rcpp::NumericMatrix& G3,
    const Rcpp::NumericMatrix& cbars,
    const Rcpp::NumericVector& logU,
    const Rcpp::NumericMatrix& logrt,
    const Rcpp::NumericMatrix& loglt,
    const Rcpp::NumericVector& logP,
    const Rcpp::NumericVector& LLconst,
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



