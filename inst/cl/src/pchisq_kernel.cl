// @library_deps: nmath
// @depends_nmath: pchisq
// @all_depends_nmath_count: 26
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, pgamma, dgamma, df, pchisq

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pchisq_kernel_temp(
    __global const double* q,
    __global const double* df,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = pchisq(q[i], df[i], lt, lp);
}
