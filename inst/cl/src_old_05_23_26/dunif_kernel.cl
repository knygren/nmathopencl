// @library_deps: nmath
// @calls_nmath: dunif
// @depends_nmath: dunif
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dunif

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dunif_kernel(
    __global const double* x,
    __global const double* min,
    __global const double* max,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dunif(x[i], min[i], max[i], gl);
}
