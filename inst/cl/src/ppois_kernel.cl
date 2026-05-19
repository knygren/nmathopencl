// @library_deps: nmath
// @depends_nmath: ppois
// @all_depends_nmath_count: 23
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma, ppois

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void ppois_kernel_temp(
    __global const double* q,
    __global const double* lambda,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = ppois(q[i], lambda[i], lt, lp);
}
