// @library_deps: nmath
// @depends_nmath: qgamma
// @all_depends_nmath_count: 39
// @all_depends_nmath: dpq, refactored, Rmath, nmath, chebyshev, cospi, dnorm, expm1, fmax2, fmin2, gammalims, lgammacor, log1p, pnorm, qnorm, gamma, lgamma, pgamma_utils, bd0, stirlerr_cycle_dependent, stirlerr, dbinom, dpois, pgamma, dgamma, gamma, lgammacor, pchisq, qchisq, qgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qgamma_kernel(
    const double p,
    const double shape,
    const double scale,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qgamma(p, shape, scale, lt_i, lp_i);
}

__kernel void qgamma_kernel_temp(
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
