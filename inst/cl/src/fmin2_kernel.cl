// @library_deps: nmath
// @depends_nmath: fmin2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fmin2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fmin2_kernel(
    const double x,
    const double y,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = fmin2(x, y);
}

__kernel void fmin2_kernel_temp(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fmin2(xv[i], yv[i]);
}
