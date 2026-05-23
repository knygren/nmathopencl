// @library_deps: nmath
// @depends_nmath: ftrunc
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, ftrunc

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void ftrunc_kernel(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = ftrunc(xv[i]);
}
