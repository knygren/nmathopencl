// @library_deps: nmath
// @depends_nmath: pgamma_utils
// @all_depends_nmath_count: 13
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void log1pmx_kernel(
    const double x,
    const double unused_y,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_y;
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = log1pmx(x);
    }
}
