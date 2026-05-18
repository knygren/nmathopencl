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
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = ptukey(q, nmeans, df, nranges, lt, lp);
}

__kernel void ptukey_kernel_temp(
    __global const double* q,
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
    out[i] = ptukey(q[i], nmeans[i], df[i], nranges[i], lt, lp);
}
