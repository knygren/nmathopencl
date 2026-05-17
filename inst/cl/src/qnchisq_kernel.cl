// @library_deps: nmath
// @depends_nmath: qnchisq
// @all_depends_nmath_count: 33
// @all_depends_nmath: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, fmin2, gammalims, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, pgamma, dgamma, qgamma, df, pchisq, pnchisq, qchisq, qnchisq

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnchisq_kernel(
    const double p,
    const double df,
    const double ncp,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnchisq(p, df, ncp, lt_i, lp_i);
}
