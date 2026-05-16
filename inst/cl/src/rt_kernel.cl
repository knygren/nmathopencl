// @library_deps: nmath
// @depends_nmath: rt
// @all_depends_nmath_count: 30
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, sexp, stirlerr_cycle_free, chebyshev, cospi, fmax2, fmin2, gammalims, lgammacor, log1p, qnorm, snorm, expm1, gamma, lgamma, pgamma_utils, rgamma, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, rchisq, rt

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rt_kernel(
    const double df,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rt(df);
}
