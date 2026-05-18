// @library_deps: nmath
// @calls_nmath: dbinom_raw
// @depends_nmath: dbinom
// @all_depends_nmath_count: 18
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dbinom_raw_kernel(
    const double x,
    const double n_size,
    const double prob,
    const double qprob,
    const double give_log_d,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dbinom_raw(x, n_size, prob, qprob, give_log);
}

__kernel void dbinom_raw_kernel_temp(
    __global const double* x,
    __global const double* n_size,
    __global const double* prob,
    __global const double* qprob,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dbinom_raw(x[i], n_size[i], prob[i], qprob[i], gl);
}
