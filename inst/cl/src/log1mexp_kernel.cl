// @library_deps: nmath
// @depends_nmath: plogis
// @all_depends_nmath_count: 6
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, plogis

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void log1mexp_kernel(
    const double x,
    const double unused_y,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_y;
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = log1mexp(x);
    }
}

__kernel void log1mexp_kernel_temp(
    __global const double* x,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = log1mexp(x[i]);
}
