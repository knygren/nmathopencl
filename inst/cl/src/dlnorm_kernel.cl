// @library_deps: nmath
// @depends_nmath: dlnorm
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dlnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dlnorm_kernel_temp(
    __global const double* x,
    __global const double* meanlog,
    __global const double* sdlog,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dlnorm(x[i], meanlog[i], sdlog[i], gl);
}
