// @library_deps: nmath
// @depends_nmath: qnbeta
// @all_depends_nmath_count: 40
// @all_depends_nmath: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pbeta, pnchisq, qbeta, qgamma, pchisq, qnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbeta_kernel(
    __global const double* p,
    __global const double* a,
    __global const double* b,
    __global const double* ncp,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qnbeta(p[i], a[i], b[i], ncp[i], lt, lp);
}
