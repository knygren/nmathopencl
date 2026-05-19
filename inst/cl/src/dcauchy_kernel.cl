// @library_deps: nmath
// @depends_nmath: dcauchy
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dcauchy

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dcauchy_kernel_temp(
    __global const double* x,
    __global const double* location,
    __global const double* scale,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dcauchy(x[i], location[i], scale[i], gl);
}
