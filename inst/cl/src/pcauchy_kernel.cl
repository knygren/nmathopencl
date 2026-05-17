// @library_deps: nmath
// @depends_nmath: pcauchy
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, pcauchy

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pcauchy_kernel(
    const double q,
    const double location,
    const double scale,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pcauchy(q, location, scale, lt, lp);
}
