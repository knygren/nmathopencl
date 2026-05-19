// @library_deps: nmath
// @depends_nmath: imax2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, imax2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void imax2_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = (double)imax2((int)x, (int)y);
}

__kernel void imax2_kernel_temp(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = (double)imax2((int)xv[i], (int)yv[i]);
}
