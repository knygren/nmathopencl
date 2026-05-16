// @library_deps: nmath
// @depends_nmath: pnf
// @all_depends_nmath_count: 36
// @all_depends_nmath: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pnbeta, df, pchisq, pnchisq, pnf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnf_kernel(
    const double x,
    const double df1,
    const double ncp,
    const double df2,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnf(x, df1, df2, ncp, 1, 0);
}
