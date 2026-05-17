// @library_deps: nmath
// @depends_nmath: dweibull
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dweibull

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dweibull_kernel(
    const double x,
    const double shape,
    const double scale,
    const double give_log_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dweibull(x, shape, scale, give_log);
}
