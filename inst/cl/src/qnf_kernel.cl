// @library_deps: nmath
// @depends_nmath: qnf
// @all_depends_nmath_count: 41
// @all_depends_nmath: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pnbeta, qgamma, qnbeta, df, pchisq, pnchisq, qchisq, qnchisq, qnf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnf_kernel(
    const double p,
    const double df1,
    const double df2,
    const double ncp,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnf(p, df1, df2, ncp, lt_i, lp_i);
}
