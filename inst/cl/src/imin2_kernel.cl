// @library_deps: nmath
// @depends_nmath: imin2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, imin2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void imin2_kernel(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = (double)imin2((int)xv[i], (int)yv[i]);
}
