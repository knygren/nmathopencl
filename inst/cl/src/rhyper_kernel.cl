// @library_deps: nmath
// @depends_nmath: rhyper
// @all_depends_nmath_count: 31
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, fmin2, gammalims, imax2, imin2, lgammacor, log1p, qnorm, gamma, lgamma, pgamma_utils, qDiscrete_search, stirlerr_cycle_dependent, bd0, lbeta, qbinom, rbinom, stirlerr, choose, dt, qhyper, rhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rhyper_kernel_temp(
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
