// @library_deps: nmath
// @depends_nmath: gamma
// @all_depends_nmath_count: 10
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void gammafn_kernel(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = gammafn(xv[i]);
}
