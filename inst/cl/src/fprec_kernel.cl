// @library_deps: nmath
// @depends_nmath: fprec
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, fprec

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void fprec_kernel_temp(
    __global const double* xv,
    __global const double* dg,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = fprec(xv[i], dg[i]);
}
