// @library_deps: nmath
// @depends_nmath: dhyper
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dhyper_kernel(
    const double x,
    const double r,
    const double b,
    const double n1,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dhyper(x, r, b, n1, 0);
}
