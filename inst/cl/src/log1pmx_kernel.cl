// @library_deps: nmath
// @depends_nmath: pgamma_utils
// @all_depends_nmath_count: 13
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void log1pmx_kernel_temp(
    __global const double* x,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = log1pmx(x[i]);
}
