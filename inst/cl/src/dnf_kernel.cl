// @library_deps: nmath
// @depends_nmath: dnf
// @all_depends_nmath_count: 27
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, dbinom, dpois, dbeta, dgamma, dnbeta, df, dchisq, dnchisq, dnf

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnf_kernel(
    const double x,
    const double df1,
    const double ncp,
    const double df2,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dnf(x, df1, df2, ncp, 0);
}
