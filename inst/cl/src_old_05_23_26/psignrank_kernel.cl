// @library_deps: nmath
// @depends_nmath: signrank
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2, signrank

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void psignrank_kernel(
    __global const double* q,
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
    out[i] = psignrank(q[i], nsize[i], lt, lp);
}
