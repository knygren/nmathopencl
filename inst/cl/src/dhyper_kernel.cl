// @library_deps: nmath
// @depends_nmath: dhyper
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dhyper_kernel(
    const double x,
    const double r,
    const double b,
    const double n1,
    const double give_log_d,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dhyper(x, r, b, n1, give_log);
}

__kernel void dhyper_kernel_temp(
    __global const double* x,
    __global const double* r,
    __global const double* b,
    __global const double* n1,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dhyper(x[i], r[i], b[i], n1[i], gl);
}
