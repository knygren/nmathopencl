// @library_deps: nmath
// @calls_nmath: lgammafn_sign
// @depends_nmath: lgamma
// @all_depends_nmath_count: 11
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void lgammafn_sign_kernel(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int sgn = 1;
    out[i] = lgammafn_sign(xv[i], &sgn);
}
