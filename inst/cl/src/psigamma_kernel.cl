// @library_deps: nmath
// @depends_nmath: polygamma
// @all_depends_nmath_count: 8
// @all_depends_nmath: Rmath, nmath, d1mach, fmax2, fmin2, i1mach, imin2, polygamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void psigamma_kernel_temp(
    __global const double* xv,
    __global const double* deriv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = psigamma(xv[i], deriv[i]);
}
