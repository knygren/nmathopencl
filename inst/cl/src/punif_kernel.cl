// @library_deps: nmath
// @depends_nmath: punif
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, punif

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void punif_kernel(
    const double x,
    const double min,
    const double max,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = punif(x, min, max, lt, lp);
}
