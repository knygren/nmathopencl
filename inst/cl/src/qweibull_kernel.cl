// @library_deps: nmath
// @depends_nmath: qweibull
// @all_depends_nmath_count: 18
// @all_depends_nmath: dpq, Rmath, nmath, stirlerr_cycle_free, chebyshev, dnorm, fmax2, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgammacor, pgamma_utils, pchisq, qgamma, qweibull

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qweibull_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = qweibull(p, shape, scale, lt_i, lp_i);
}

__kernel void qweibull_kernel_temp(
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
    out[i] = qweibull(p[i], shape[i], scale[i], lt, lp);
}
