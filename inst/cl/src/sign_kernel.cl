// @library_deps: nmath
// @depends_nmath: sign
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, sign

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void sign_kernel_temp(
    __global const double* xv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = sign(xv[i]);
}
