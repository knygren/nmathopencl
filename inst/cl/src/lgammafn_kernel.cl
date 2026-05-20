// @library_deps: nmath
// @depends_nmath: lgamma
// @all_depends_nmath_count: 11
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void lgammafn_kernel_temp(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = lgammafn(xv[i]);
}
