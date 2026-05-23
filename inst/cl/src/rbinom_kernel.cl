// rbinom_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in nmath RNG globals.

// @library_deps: nmath
// @depends_nmath: rbinom
// @all_depends_nmath_count: 36
// @all_depends_nmath: dpq, qDiscrete_search, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pbeta, pbinom, qbinom, rbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rbinom_kernel(
    const double size,
    const double prob,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = rbinom(size, prob);
    }
}
