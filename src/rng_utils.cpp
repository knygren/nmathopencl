// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#include "nmath_local.h"
#include "dpq_local.h"


#include "rng_utils.h"
#include <random>



// Thread-local RNG and distribution
thread_local std::mt19937 safe_rng_engine(std::random_device{}());
thread_local std::uniform_real_distribution<> safe_rng_dist(0.0, 1.0);

using namespace glmbayes::rng;


// log P(X <= d) for X ~ InvGamma(shape, rate)
// X = 1/Y, Y ~ Gamma(shape, rate)
// P(X <= d) = P(Y >= 1/d) = upper-tail Gamma at 1/d
double log_p_inv_gamma_safe(double dispersion,
                            double shape,
                            double rate) {
  double y = 1.0 / dispersion;
  
  // pgamma_local(x, shape, scale, lower_tail, log_p)
  return pgamma_local(y,
                      shape,
                      1.0 / rate,
                      /*lower_tail=*/0,
                      /*log_p=*/1);  // log upper tail
}


// Safe inverse-gamma CDF using nmath/rmath pgamma
double p_inv_gamma_safe(double dispersion,
                        double shape,
                        double rate) {
  // For X ~ InvGamma(shape, rate), Y = 1/X ~ Gamma(shape, rate)
  // So P(X <= d) = P(Y >= 1/d) = 1 - F_Y(1/d)
  double y = 1.0 / dispersion;
  
  // Call the ported pgamma (not R::pgamma)
  // Arguments: x, shape, scale, lower_tail, log_p
  double Fy = pgamma_local(y, shape, 1.0 / rate, /*lower_tail=*/1, /*log_p=*/0);
  
  return 1.0 - Fy;
}


// double q_inv_gamma_safe(double p,
//                         double shape,
//                         double rate,
//                         double disp_upper,
//                         double disp_lower) {
//   // Compute probabilities at the bounds using safe pgamma
//   double p_upp = p_inv_gamma_safe(disp_upper, shape, rate);
//   double p_low = p_inv_gamma_safe(disp_lower, shape, rate);
//   
//   // Map uniform p into [p_low, p_upp]
//   double p1 = p_low + p * (p_upp - p_low);
//   double p2 = 1.0 - p1;
//   
//   // Invert via safe qgamma (ported from nmath/rmath)
//   return 1.0 / qgamma_local(p2, shape, 1.0 / rate, /*lower_tail=*/1, /*log_p=*/0);
// }


double q_inv_gamma_safe(double u,
                        double shape,
                        double rate,
                        double disp_upper,
                        double disp_lower) {
  // log CDF at bounds
  double lg_low = log_p_inv_gamma_safe(disp_lower, shape, rate);
  double lg_upp = log_p_inv_gamma_safe(disp_upper, shape, rate);
  
  // ensure lg_upp >= lg_low (it should be, but be defensive)
  if (lg_upp <= lg_low) {
    // interval numerically collapsed: fall back to a boundary
    return disp_upper;
  }
  
  // We want p1 = p_low + u * (p_upp - p_low)
  // with p_low = exp(lg_low), p_upp = exp(lg_upp).
  //
  // Write:
  //   p1 = exp(lg_low) + u * (exp(lg_upp) - exp(lg_low))
  //       = exp(lg_low) * [1 + u * (exp(lg_upp - lg_low) - 1)]
  //
  // So:
  //   log p1 = lg_low + log(1 + u * (exp(lg_upp - lg_low) - 1))
  
  double diff   = lg_upp - lg_low;          // > 0
  double expdif = std::exp(diff);           // exp(lg_upp - lg_low)
  double inner  = 1.0 + u * (expdif - 1.0); // in (1, expdif]
  
  double lg_p1  = lg_low + std::log(inner);
  
  // Now p2 = 1 - p1, but we stay in log-space:
  // log p2 = log(1 - exp(lg_p1))
  double lg_p2 = std::log1p(-std::exp(lg_p1));
  
  // Invert Gamma CDF in log-p mode
  double y = qgamma_local(lg_p2,
                          shape,
                          1.0 / rate,
                          /*lower_tail=*/1,
                          /*log_p=*/1);
                          
                          if (!std::isfinite(y) || y <= 0.0) {
                            return disp_upper;  // safe fallback, never 0
                          }
                          
                          return 1.0 / y;
}





namespace glmbayes {

namespace rng {

// Core sampling function
double runif_safe() {
  return safe_rng_dist(safe_rng_engine);
}


// 
// // Declaration (e.g. in a header if needed)
// // double rinvgamma_safe(double shape, double rate,
// //                        double disp_upper, double disp_lower);
// 
// // Definition (in your .cpp file)
double rinvgamma_ct_safe(double shape,
                       double rate,
                       double disp_upper,
                       double disp_lower) {
  // draw uniform(0,1) from thread‑local RNG
  double p = runif_safe();
  
  // invert CDF at p to get inverse‑gamma draw
  // q_inv_gamma must be pure C++ math, no R calls
  return q_inv_gamma_safe(p, shape, rate, disp_upper, disp_lower);
  
  
}

}
}
