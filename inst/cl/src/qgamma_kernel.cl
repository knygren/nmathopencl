// @library_deps: nmath
// @depends_nmath: qgamma
// @all_depends_nmath_count: 25
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma, dgamma, qgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qgamma_kernel(
    const double p,
    const double shape,
    const double scale,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qgamma(p, shape, scale, 1, 0);
}
