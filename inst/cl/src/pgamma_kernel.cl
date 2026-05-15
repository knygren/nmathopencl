// @library_deps: nmath
// @calls_nmath: pgamma
// @depends_nmath: pgamma
// @all_depends_nmath_count: 22
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pgamma_kernel(
    const double x,
    const double shape,
    const double scale,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pgamma(x, shape, scale, 1, 0);
}
