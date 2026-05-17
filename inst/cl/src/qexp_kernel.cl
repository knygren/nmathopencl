// @library_deps: nmath
// @depends_nmath: qexp
// @all_depends_nmath_count: 11
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, pnorm, qnorm, gamma, lgammacor, qexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qexp_kernel(
    const double p,
    const double rate,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qexp(p, rate, lt_i, lp_i);
}
