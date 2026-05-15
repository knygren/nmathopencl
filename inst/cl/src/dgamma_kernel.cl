// @library_deps: nmath
// @calls_nmath: dgamma
// @depends_nmath: dgamma
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, dgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dgamma_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = dgamma(x, shape, scale, 0);
}
