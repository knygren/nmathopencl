// @library_deps: nmath
// @calls_nmath: pgamma
// @depends_nmath: pgamma
// @all_depends_nmath_count: 22
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pgamma_kernel(
    const double q,
    const double shape,
    const double scale,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pgamma(q, shape, scale, lt, lp);
}
