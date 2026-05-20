// @library_deps: nmath
// @depends_nmath: imax2
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, imax2

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void imax2_kernel(
    __global const double* xv,
    __global const double* yv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = (double)imax2((int)xv[i], (int)yv[i]);
}
