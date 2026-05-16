// @library_deps: nmath
// @depends_nmath: dnt
// @all_depends_nmath_count: 36
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, dt, pgamma, toms708, dgamma, pbeta, pt, df, pnt, dnt

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnt_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = dnt(x, df, ncp, 0);
}
