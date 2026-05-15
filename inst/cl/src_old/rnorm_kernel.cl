// rnorm_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif/snorm globals.

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

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
