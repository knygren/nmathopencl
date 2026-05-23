// @library_deps: nmath
// @depends_nmath: dnbeta
// @all_depends_nmath_count: 22
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, dbinom, dpois, dbeta, dnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnbeta_kernel(
    __global const double* x,
    __global const double* a,
    __global const double* ncp,
    __global const double* b,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dnbeta(x[i], a[i], b[i], ncp[i], gl);
}
