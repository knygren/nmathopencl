// @library_deps: nmath
// @depends_nmath: qgamma
// @all_depends_nmath_count: 25
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma, dgamma, qgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qgamma_kernel(
    __global const double* p,
    __global const double* shape,
    __global const double* scale,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qgamma(p[i], shape[i], scale[i], lt, lp);
}
