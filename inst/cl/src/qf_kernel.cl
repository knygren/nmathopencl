// @library_deps: nmath
// @depends_nmath: qf
// @all_depends_nmath_count: 37
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pbeta, qbeta, qgamma, df, qchisq, qf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qf_kernel(
    const double p,
    const double df1,
    const double df2,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qf(p, df1, df2, 1, 0);
}
