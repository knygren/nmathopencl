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
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qtukey(p, nmeans, df, nranges, lt_i, lp_i);
}

__kernel void qtukey_kernel_temp(
    __global const double* p,
    __global const double* nmeans,
    __global const double* df,
    __global const double* nranges,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qtukey(p[i], nmeans[i], df[i], nranges[i], lt, lp);
}
