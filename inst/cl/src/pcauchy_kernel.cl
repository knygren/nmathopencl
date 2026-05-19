// @library_deps: nmath
// @depends_nmath: pcauchy
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, pcauchy

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pcauchy_kernel_temp(
    __global const double* q,
    __global const double* location,
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
    out[i] = pcauchy(q[i], location[i], scale[i], lt, lp);
}
