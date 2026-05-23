// @library_deps: nmath
// @depends_nmath: qbinom
// @all_depends_nmath_count: 33
// @all_depends_nmath: dpq, qDiscrete_search, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pbeta, pbinom, qbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qbinom_kernel(
    __global const double* size,
    __global const double* prob,
    __global const double* p,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qbinom(p[i], size[i], prob[i], lt, lp);
}
