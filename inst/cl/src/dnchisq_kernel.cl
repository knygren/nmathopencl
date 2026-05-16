// @library_deps: nmath
// @depends_nmath: dnchisq
// @all_depends_nmath_count: 23
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, dchisq, dnchisq

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnchisq_kernel(
    const double x,
    const double df,
    const double ncp,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dnchisq(x, df, ncp, 0);
}
