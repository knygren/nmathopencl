// dnorm_kernel.cl
// Vectorized wrapper kernel for the public Mathlib dnorm interface.
// @library_deps: nmath
// @calls_nmath: dnorm4
// @depends_nmath: dnorm

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
