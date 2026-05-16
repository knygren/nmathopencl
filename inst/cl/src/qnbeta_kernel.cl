// @library_deps: nmath
// @depends_nmath: qnbeta
// @all_depends_nmath_count: 30
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pnbeta, qnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbeta_kernel(
    const double unused_x,
    const double a,
    const double ncp,
    const double b,
    const double p,
    __global double* out,
    const int n
) {
    (void)unused_x;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbeta(p, a, b, ncp, 1, 0);
}
