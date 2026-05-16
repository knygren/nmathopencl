// @library_deps: nmath
// @depends_nmath: qtukey
// @all_depends_nmath_count: 24
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, pnorm, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, ptukey, qtukey

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qtukey_kernel(
    const double p,
    const double nmeans,
    const double df,
    const double nranges,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qtukey(p, nmeans, df, nranges, 1, 0);
}
