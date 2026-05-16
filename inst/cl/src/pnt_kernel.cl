// @library_deps: nmath
// @depends_nmath: pnt
// @all_depends_nmath_count: 34
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pbeta, pt, df, pnt

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnt_kernel(
    const double x,
    const double df,
    const double ncp,
    const double unused_df2,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_df2; (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnt(x, df, ncp, 1, 0);
}
