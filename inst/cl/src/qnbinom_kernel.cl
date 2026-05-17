// @library_deps: nmath
// @depends_nmath: qnbinom
// @all_depends_nmath_count: 9
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search, qnbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_kernel(
    const double p,
    const double size,
    const double prob,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbinom(p, size, prob, lt_i, lp_i);
}
