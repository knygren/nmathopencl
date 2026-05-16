// @library_deps: nmath
// @depends_nmath: qweibull
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, qweibull

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qweibull_kernel(
    const double p,
    const double shape,
    const double scale,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qweibull(p, shape, scale, 1, 0);
}
