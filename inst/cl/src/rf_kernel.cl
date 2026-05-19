// @library_deps: nmath
// @depends_nmath: rf
// @all_depends_nmath_count: 30
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, sexp, stirlerr_cycle_free, chebyshev, cospi, fmax2, fmin2, gammalims, lgammacor, log1p, qnorm, snorm, expm1, gamma, lgamma, pgamma_utils, rgamma, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, rchisq, rf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rf_kernel(
    const double df1,
    const double df2,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rf(df1, df2);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rf_kernel_temp(
    const double df1,
    const double df2,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rf(df1, df2);
}
