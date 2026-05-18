// @library_deps: nmath
// @depends_nmath: dnt
// @all_depends_nmath_count: 36
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, dt, pgamma, toms708, dgamma, pbeta, pt, df, pnt, dnt

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnt_kernel(
    const double x,
    const double df,
    const double ncp,
    const double give_log_d,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dnt(x, df, ncp, give_log);
}

__kernel void dnt_kernel_temp(
    __global const double* x,
    __global const double* df,
    __global const double* ncp,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dnt(x[i], df[i], ncp[i], gl);
}
