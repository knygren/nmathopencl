// @library_deps: nmath
// @depends_nmath: dnbinom
// @all_depends_nmath_count: 20
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dnbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnbinom_mu_kernel(
    const double x,
    const double size,
    const double mu,
    const double give_log_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dnbinom_mu(x, size, mu, give_log);
}

__kernel void dnbinom_mu_kernel_temp(
    __global const double* x,
    __global const double* size,
    __global const double* mu,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dnbinom_mu(x[i], size[i], mu[i], gl);
}
