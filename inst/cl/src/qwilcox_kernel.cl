// @library_deps: nmath
// @depends_nmath: qwilcox
// @all_depends_nmath_count: 37
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, stirlerr_cycle_free, chebyshev, fprec, fround, dnorm, fmax2, fmin2, lgamma_sim, pchisq, qnorm, stirlerr, dt, pchisq, pt, qwilcox, wilcox_free

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qwilcox_kernel(
    const double p,
    const double m,
    const double n2,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qwilcox(p, m, n2, lt_i, lp_i);
}
