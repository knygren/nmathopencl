// @library_deps: nmath
// @depends_nmath: qbeta
// @all_depends_nmath_count: 37
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, lgammacor, log1p, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, beta, dbinom, dpois, pgamma, dgamma, pbeta, qbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qbeta_kernel(
    const double p,
    const double a,
    const double b,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qbeta(p, a, b, lt_i, lp_i);
}
