// @library_deps: nmath
// @depends_nmath: pf
// @all_depends_nmath_count: 33
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pbeta, df, pchisq, pf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pf_kernel(
    const double x,
    const double df1,
    const double df2,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pf(x, df1, df2, lt, lp);
}
