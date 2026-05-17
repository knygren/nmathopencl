// @library_deps: nmath
// @depends_nmath: dnbeta
// @all_depends_nmath_count: 22
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, dbinom, dpois, dbeta, dnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnbeta_kernel(
    const double x,
    const double a,
    const double ncp,
    const double b,
    const double give_log_d,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dnbeta(x, a, b, ncp, give_log);
}
