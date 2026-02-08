#pragma once
#include <Rcpp.h>

// -----------------------------------------------------------------------------
//  R_interface.h
//
//  Centralized, static‑cached accessors for R functions used across the C++
//  codebase.  This header provides a clean, explicit C++ → R boundary and
//  eliminates repeated dynamic lookups scattered throughout the source files.
//
//  Only *global, non‑family‑specific* R functions belong here.
//  Family‑dependent functions (f2, f3, glmbfamfunc, etc.) must remain
//  runtime arguments and should NOT be wrapped here.
// -----------------------------------------------------------------------------

namespace glmbayes_R {

// -----------------------------------------------------------------------------
//  Time / formatting utilities
// -----------------------------------------------------------------------------

inline Rcpp::Function r_format() {
  static Rcpp::Function fn("format");
  return fn;
}

inline Rcpp::Function r_sys_time() {
  static Rcpp::Function fn("Sys.time");
  return fn;
}

// inline std::string timestamp() {
//   return Rcpp::as<std::string>( r_format()( r_sys_time()() ) );
// }


// -----------------------------------------------------------------------------
//  Basic coercion helpers
// -----------------------------------------------------------------------------

inline Rcpp::Function r_as_matrix() {
  static Rcpp::Function fn("as.matrix");
  return fn;
}

inline Rcpp::Function r_as_vector() {
  static Rcpp::Function fn("as.vector");
  return fn;
}

inline Rcpp::Function r_as_numeric() {
  static Rcpp::Function fn("as.numeric");
  return fn;
}


// -----------------------------------------------------------------------------
//  Grid / envelope helpers
// -----------------------------------------------------------------------------

inline Rcpp::Function r_expand_grid() {
  static Rcpp::Function fn("expand.grid");
  return fn;
}

inline Rcpp::Function r_envelope_opt() {
  static Rcpp::Function fn("EnvelopeOpt");
  return fn;
}

inline Rcpp::Function r_envelope_sort() {
  static Rcpp::Function fn("EnvelopeSort");
  return fn;
}


// -----------------------------------------------------------------------------
//  Interactive / readline utilities
// -----------------------------------------------------------------------------

inline Rcpp::Function r_interactive() {
  static Rcpp::Function fn("interactive");
  return fn;
}

inline Rcpp::Function r_readline() {
  static Rcpp::Function fn("readline");
  return fn;
}


// -----------------------------------------------------------------------------
//  Distribution helpers (Gamma/Gaussian samplers)
// -----------------------------------------------------------------------------

inline Rcpp::Function r_qgamma() {
  static Rcpp::Function fn("qgamma");
  return fn;
}

inline Rcpp::Function r_rgamma_ct() {
  static Rcpp::Function fn("rgamma_ct");
  return fn;
}

inline Rcpp::Function r_runif() {
  static Rcpp::Function fn("runif");
  return fn;
}


// -----------------------------------------------------------------------------
//  Optimization / model‑fitting helpers
// -----------------------------------------------------------------------------

inline Rcpp::Function r_optim() {
  static Rcpp::Function fn("optim");
  return fn;
}

inline Rcpp::Function r_try() {
  static Rcpp::Function fn("try");
  return fn;
}

inline Rcpp::Function r_lm_fit() {
  static Rcpp::Function fn("lm.fit");
  return fn;
}

inline Rcpp::Function r_lm_wfit() {
  static Rcpp::Function fn("lm.wfit");
  return fn;
}

inline Rcpp::Function r_gaussian() {
  static Rcpp::Function fn("gaussian");
  return fn;
}

inline Rcpp::Function r_rNormal_reg_wfit() {
  static Rcpp::Function fn("rNormal_reg.wfit");
  return fn;
}


// -----------------------------------------------------------------------------
//  System utilities
// -----------------------------------------------------------------------------

inline Rcpp::Function r_system_file() {
  static Rcpp::Function fn("system.file");
  return fn;
}

} // namespace glmbayes_R


//////////////////////////////////////////////////////////////////////////////////////



// EnvelopeBuild_cpp

// Rcpp::Function EnvelopeOpt("EnvelopeOpt");
// Rcpp::Function expGrid("expand.grid");
// Rcpp::Function asMat("as.matrix");
// Rcpp::Function EnvSort("EnvelopeSort");


//Rcpp::Function(\"format\")

//Rcpp::Function(\"Sys.time\")

// EnvelopeBuild_Ind_Normal_Gamma.cpp

//Rcpp::Function EnvelopeOpt(\"EnvelopeOpt\");
//Rcpp::Function expGrid(\"expand.grid\");"    
//Rcpp::Function asMat(\"as.matrix\");         
//Rcpp::Function EnvSort(\"EnvelopeSort\");   


// EnvelopeDispersionBuild.cpp (two of these are function arguments)
                             
                             
// Rcpp::Function& parallel_fn," 
// Rcpp::Function(\"as.numeric\")
// Rcpp::Function(\"Sys.time\")
// Rcpp::Function& ub2_parallel_fn


//EnvelopeEval.cpp

//Rcpp::Function(\"format\")
//Rcpp::Function(\"Sys.time\")
//Rcpp::Function r_interactive(\"interactive\");"
// Rcpp::Function readline(\"readline\");" 
//

//EnvelopeOrchestrator.cpp

//Rcpp::Function EnvelopeSort = pkg[\"EnvelopeSort\"];


//EnvelopeSize.cpp

//Rcpp::Function EnvelopeOpt(\"EnvelopeOpt\");
//

//export_wrappers.cpp (likely function arguments)

// const Rcpp::Function& f2,
// const Rcpp::Function& f3,


// kernel_loader.cpp

// Rcpp::Function(\"system.file\")


// rGammaGamma.cpp

// Rcpp::Function qgamma(\"qgamma\");
// Rcpp::Function rgamma_ct(\"rgamma_ct\");
// Rcpp::Function runif(\"runif\");


// rGammaGaussian.cpp

// Rcpp::Function rgamma_ct(\"rgamma_ct\");


//rIndepNormalGammaReg.cpp

// Rcpp::Function interactive = base[\"interactive\"];
// Rcpp::Function(\"format\")
// Rcpp::Function(\"Sys.time\")
// Rcpp::Function readline(\"readline\");
// Rcpp::Function fmt(\"format\");
// Rcpp::Function(\"as.numeric\")
// Rcpp::Function lm_wfit(\"lm.wfit\");
// Rcpp::Function optim(\"optim\");
// Rcpp::Function gaussian(\"gaussian\");
// Rcpp::Function glmbfamfunc = glmbayes_ns[\"glmbfamfunc\"];
// Rcpp::Function f2 = famfunc[\"f2\"];
// Rcpp::Function f3 = famfunc[\"f3\"];

// rNormalGammaReg.cpp



                                  
//Rcpp::Function rNormal_reg_wfit(\"rNormal_reg.wfit\");
//Rcpp::Function glmbfamfunc(\"glmbfamfunc\");          
//Rcpp::Function gaussian(\"gaussian\");       
                                  
// rNormalGLM.cpp


// Rcpp::Function asVec(\"as.vector\");
// Rcpp::Function r_interactive(\"interactive\");
// Rcpp::Function readline(\"readline\");
// Rcpp::Function(\"format\")
// Rcpp::Function(\"Sys.time\")
// Rcpp::Function asMat(\"as.matrix\");
// Rcpp::Function asVec(\"as.vector\");
// Rcpp::Function optfun(\"optim\");
// Rcpp::Function tryfun(\"try\");



// rNormalReg.cpp


// Rcpp::Function asMat(\"as.matrix\");
// Rcpp::Function asVec(\"as.vector\");
// Rcpp::Function lm_fit_fun(\"lm.fit\");


Rcpp::Function rNormal_reg_wfit(\"rNormal_reg.wfit\");"





                                  [[13]]$text
                                  [1] "  Rcpp::Function rNormal_reg_wfit(\"rNormal_reg.wfit\");"
                                  [2] "  Rcpp::Function glmbfamfunc(\"glmbfamfunc\");"          
                                  [3] "  Rcpp::Function gaussian(\"gaussian\");"                
                                  















