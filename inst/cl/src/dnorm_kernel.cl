// @library_deps: nmath
// @calls_nmath: dnorm
// @depends_nmath: dnorm
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnorm_kernel_temp(
    __global const double* x,
    __global const double* mu,
    __global const double* sigma,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dnorm(x[i], mu[i], sigma[i], gl);
}
