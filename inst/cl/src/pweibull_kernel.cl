// @library_deps: nmath
// @depends_nmath: pweibull
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, expm1, pweibull

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pweibull_kernel(
    const double q,
    const double shape,
    const double scale,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pweibull(q, shape, scale, lt, lp);
}

__kernel void pweibull_kernel_temp(
    __global const double* q,
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
    out[i] = pweibull(q[i], shape[i], scale[i], lt, lp);
}
