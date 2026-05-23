// @library_deps: nmath
// @depends_nmath: fsign
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fsign

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fsign_kernel(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fsign(xv[i], yv[i]);
}
