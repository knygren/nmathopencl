// @library_deps: nmath
// @calls_nmath: lgammafn_sign
// @depends_nmath: lgamma
// @all_depends_nmath_count: 11
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void lgammafn_sign_kernel(
    const double x,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        int sgn = 1;
        out[i] = lgammafn_sign(x, &sgn);
    }
}

__kernel void lgammafn_sign_kernel_temp(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int sgn = 1;
    out[i] = lgammafn_sign(xv[i], &sgn);
}
