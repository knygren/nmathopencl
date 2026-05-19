// @library_deps: nmath
// @depends_nmath: qnt
// @all_depends_nmath_count: 43
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, dt, nt, pgamma, toms708, dt, pt, qt, qt, dnt

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnt_kernel_temp(
    __global const double* p,
    __global const double* df,
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
    out[i] = qnt(p[i], df[i], ncp[i], lt, lp);
}
