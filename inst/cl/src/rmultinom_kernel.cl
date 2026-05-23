// @library_deps: nmath
// @depends_nmath: rmultinom
// @all_depends_nmath_count: 37
// @all_depends_nmath: dpq, qDiscrete_search, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pbeta, pbinom, qbinom, rbinom, rmultinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rmultinom_kernel(
    const double size,
    const double prob,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    double pvec[2];
    int rN[2];
    pvec[0] = prob;
    pvec[1] = 1.0 - prob;
    for (int i = 0; i < n; ++i) {
        rmultinom((int)size, pvec, 2, rN);
        out[i] = (double)rN[0];
    }
}
