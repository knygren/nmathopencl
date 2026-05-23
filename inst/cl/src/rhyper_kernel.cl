// @library_deps: nmath
// @depends_nmath: rhyper
// @all_depends_nmath_count: 42
// @all_depends_nmath: dpq, qDiscrete_search, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, imax2, imin2, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, choose, dpois, dt, pgamma, qhyper, toms708, pbeta, pbinom, qbinom, rbinom, rhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rhyper_kernel(
    const double r,
    const double b,
    const double n1,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rhyper(r, b, n1);
}
