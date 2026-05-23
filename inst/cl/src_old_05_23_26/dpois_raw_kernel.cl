// @library_deps: nmath
// @calls_nmath: dpois_raw
// @depends_nmath: dpois
// @all_depends_nmath_count: 18
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dpois_raw_kernel(
    __global const double* x,
    __global const double* lambda,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dpois_raw(x[i], lambda[i], gl);
}
