// @library_deps: nmath
// @depends_nmath: fmin2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fmin2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fmin2_kernel(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fmin2(xv[i], yv[i]);
}
