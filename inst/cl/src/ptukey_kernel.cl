// @library_deps: nmath
// @depends_nmath: ptukey
// @all_depends_nmath_count: 23
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, pnorm, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, ptukey

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void ptukey_kernel(
    const double q,
    const double nmeans,
    const double df,
    const double nranges,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = ptukey(q, nmeans, df, nranges, 1, 0);
}
