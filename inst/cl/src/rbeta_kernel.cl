// @library_deps: nmath
// @depends_nmath: rbeta
// @all_depends_nmath_count: 17
// @all_depends_nmath: refactored, Rmath, sunif, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, fmin2, gammalims, lgammacor, log1p, gamma, lgamma, lbeta, beta, rbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rbeta_kernel(
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
    for (int i = 0; i < n; ++i) out[i] = rbeta(a, b);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rbeta_kernel_temp(
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
    for (int i = 0; i < n; ++i) out[i] = rbeta(a, b);
}
