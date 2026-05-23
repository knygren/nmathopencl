// rnorm_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif/snorm globals.

// @library_deps: nmath
// @depends_nmath: rnorm
// @all_depends_nmath_count: 11
// @all_depends_nmath: dpq, Rmath, sunif, nmath, chebyshev, fmax2, fmin2, log1p, qnorm, snorm, rnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rnorm_kernel(
    const double mu,
    const double sigma,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = rnorm(mu, sigma);
    }
}
