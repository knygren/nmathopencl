// @library_deps: nmath
// @depends_nmath: pgamma
// @all_depends_nmath_count: 22
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, dnorm, fmax2, gammalims, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void logspace_add_kernel(
    const double logx,
    const double logy,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = logspace_add(logx, logy);
    }
}

__kernel void logspace_add_kernel_temp(
    __global const double* logxv,
    __global const double* logyv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = logspace_add(logxv[i], logyv[i]);
}
