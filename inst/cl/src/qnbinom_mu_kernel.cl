// @library_deps: nmath
// @depends_nmath: qnbinom_mu
// @all_depends_nmath_count: 35
// @all_depends_nmath: dpq, qDiscrete_search, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, ppois, qpois, toms708, pbeta, pnbinom, qnbinom_mu

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_mu_kernel(
    __global const double* p,
    __global const double* size,
    __global const double* mu,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qnbinom_mu(p[i], size[i], mu[i], lt, lp);
}
