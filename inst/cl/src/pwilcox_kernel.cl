// @library_deps: nmath
// @depends_nmath: wilcox
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, log1p, gamma, lgamma, lbeta, choose, wilcox

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pwilcox_kernel(
    const double q,
    const double m,
    const double n2,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pwilcox(q, m, n2, lt, lp);
}
