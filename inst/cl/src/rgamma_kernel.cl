// @library_deps: nmath
// @depends_nmath: rgamma
// @all_depends_nmath_count: 13
// @all_depends_nmath: dpq, Rmath, sunif, nmath, sexp, chebyshev, fmax2, fmin2, log1p, qnorm, snorm, expm1, rgamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rgamma_kernel(
    const double shape,
    const double scale,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rgamma(shape, scale);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rgamma_kernel_temp(
    const double shape,
    const double scale,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rgamma(shape, scale);
}
