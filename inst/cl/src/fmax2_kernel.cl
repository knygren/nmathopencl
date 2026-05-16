// @library_deps: nmath
// @depends_nmath: fmax2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fmax2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fmax2_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = fmax2(x, y);
}
