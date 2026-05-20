// @library_deps: nmath
// @depends_nmath: fround
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fround

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fround_kernel(
    __global const double* xv,
    __global const double* dg,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fround(xv[i], dg[i]);
}
