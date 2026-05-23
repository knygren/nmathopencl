// @library_deps: nmath
// @depends_nmath: pnbeta
// @all_depends_nmath_count: 28
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnbeta_kernel(
    __global const double* q,
    __global const double* shape1,
    __global const double* shape2,
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
    out[i] = pnbeta(q[i], shape1[i], shape2[i], ncp[i], lt, lp);
}
