// @library_deps: nmath
// @depends_nmath: pnchisq
// @all_depends_nmath_count: 29
// @all_depends_nmath: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, fmin2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, pgamma, dgamma, df, pchisq, pnchisq

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnchisq_kernel(
    const double x,
    const double df,
    const double ncp,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnchisq(x, df, ncp, lt, lp);
}
