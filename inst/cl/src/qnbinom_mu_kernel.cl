// @library_deps: nmath
// @depends_nmath: qnbinom_mu
// @all_depends_nmath_count: 10
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search, qpois, qnbinom_mu

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_mu_kernel(
    const double p,
    const double size,
    const double mu,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbinom_mu(p, size, mu, lt_i, lp_i);
}

__kernel void qnbinom_mu_kernel_temp(
    __global const double* p,
    __global const double* size,
    __global const double* mu,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qnbinom_mu(p[i], size[i], mu[i], lt, lp);
}
