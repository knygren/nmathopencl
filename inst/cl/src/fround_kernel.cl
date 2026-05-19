// @library_deps: nmath
// @depends_nmath: fround
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fround

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fround_kernel(
    const double x,
    const double digits,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = fround(x, digits);
}

__kernel void fround_kernel_temp(
    __global const double* xv,
    __global const double* dg,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fround(xv[i], dg[i]);
}
