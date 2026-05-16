// @library_deps: nmath
// @depends_nmath: pnbeta
// @all_depends_nmath_count: 28
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnbeta_kernel(
    const double x,
    const double a,
    const double ncp,
    const double b,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnbeta(x, a, b, ncp, 1, 0);
}
