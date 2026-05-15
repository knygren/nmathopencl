// dnorm_kernel.cl
// Vectorized wrapper kernel for the public Mathlib dnorm interface.

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnorm_kernel(
    __global const double* x,
    const double mu,
    const double sigma,
    const int give_log,
    __global double* out,
    const int n
) {
    int i = get_global_id(0);
    if (i >= n) return;

    out[i] = dnorm(x[i], mu, sigma, give_log);
}
