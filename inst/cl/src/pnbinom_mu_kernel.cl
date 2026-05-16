// @library_deps: nmath
// @depends_nmath: pnbinom
// @all_depends_nmath_count: 30
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, ppois, toms708, pbeta, pnbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnbinom_mu_kernel(
    const double q,
    const double size,
    const double mu,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnbinom_mu(q, size, mu, 1, 0);
}
