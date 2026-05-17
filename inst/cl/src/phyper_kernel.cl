// @library_deps: nmath
// @depends_nmath: phyper
// @all_depends_nmath_count: 20
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dhyper, phyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void phyper_kernel(
    const double q,
    const double m,
    const double n_black,
    const double k,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = phyper(q, m, n_black, k, lt, lp);
}
