// @library_deps: nmath
// @depends_nmath: rlnorm
// @all_depends_nmath_count: 12
// @all_depends_nmath: dpq, Rmath, sunif, nmath, chebyshev, fmax2, fmin2, log1p, qnorm, snorm, rnorm, rlnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rlnorm_kernel(
    const double meanlog,
    const double sdlog,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rlnorm(meanlog, sdlog);
}
