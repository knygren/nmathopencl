// @library_deps: nmath
// @depends_nmath: signrank
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2, signrank

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qsignrank_kernel(
    const double p,
    const double nsize,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qsignrank(p, nsize, lt_i, lp_i);
}

__kernel void qsignrank_kernel_temp(
    __global const double* p,
    __global const double* nsize,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qsignrank(p[i], nsize[i], lt, lp);
}
