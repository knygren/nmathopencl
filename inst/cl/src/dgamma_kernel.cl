// @library_deps: nmath
// @calls_nmath: dgamma
// @depends_nmath: dgamma
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, dgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dgamma_kernel(
    const double x,
    const double shape,
    const double scale,
    const double give_log_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dgamma(x, shape, scale, give_log);
}

__kernel void dgamma_kernel_temp(
    __global const double* x,
    __global const double* shape,
    __global const double* scale,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dgamma(x[i], shape[i], scale[i], gl);
}
