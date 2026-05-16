// @library_deps: nmath
// @depends_nmath: gamma
// @all_depends_nmath_count: 10
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void gammafn_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = gammafn(x);
}
