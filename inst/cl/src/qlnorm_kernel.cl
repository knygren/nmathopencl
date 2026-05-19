// @library_deps: nmath
// @depends_nmath: qlnorm
// @all_depends_nmath_count: 20
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, dnorm, fmax2, log1p, pnorm, qnorm, qlnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qlnorm_kernel(
    const double p,
    const double meanlog,
    const double sdlog,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qlnorm(p, meanlog, sdlog, lt_i, lp_i);
}

__kernel void qlnorm_kernel_temp(
    __global const double* p,
    __global const double* meanlog,
    __global const double* sdlog,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qlnorm(p[i], meanlog[i], sdlog[i], lt, lp);
}
