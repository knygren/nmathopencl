// @library_deps: nmath
// @depends_nmath: polygamma
// @all_depends_nmath_count: 8
// @all_depends_nmath: Rmath, nmath, d1mach, fmax2, fmin2, i1mach, imin2, polygamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pentagamma_kernel(
    const double x,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pentagamma(x);
}

__kernel void pentagamma_kernel_temp(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = pentagamma(xv[i]);
}
