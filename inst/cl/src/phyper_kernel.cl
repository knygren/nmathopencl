// @library_deps: nmath
// @depends_nmath: phyper
// @all_depends_nmath_count: 20
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dhyper, phyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void phyper_kernel_temp(
    __global const double* q,
    __global const double* m,
    __global const double* n_black,
    __global const double* k,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = phyper(q[i], m[i], n_black[i], k[i], lt, lp);
}
