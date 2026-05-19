// @library_deps: nmath
// @depends_nmath: beta
// @all_depends_nmath_count: 14
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, lbeta, beta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void beta_special_kernel(
    const double a,
    const double b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = beta(a, b);
}

__kernel void beta_special_kernel_temp(
    __global const double* av,
    __global const double* bv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = beta(av[i], bv[i]);
}
