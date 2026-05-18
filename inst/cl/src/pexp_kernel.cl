// @library_deps: nmath
// @depends_nmath: pexp
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, expm1, pexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pexp_kernel(
    const double q,
    const double rate,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pexp(q, rate, lt, lp);
}

__kernel void pexp_kernel_temp(
    __global const double* q,
    __global const double* rate,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = pexp(q[i], rate[i], lt, lp);
}
