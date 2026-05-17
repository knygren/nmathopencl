// @library_deps: nmath
// @depends_nmath: signrank
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2, signrank

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void psignrank_kernel(
    const double q,
    const double nsize,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = psignrank(q, nsize, lt, lp);
}
