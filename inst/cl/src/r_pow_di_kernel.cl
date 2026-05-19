// @depends_nmath: none
// @all_depends_nmath_count: 0

#pragma OPENCL EXTENSION cl_khr_fp64 : enable


__kernel void r_pow_di_kernel_temp(
    __global const double* xv,
    __global const double* n_exp_d_col,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = R_pow_di(xv[i], (int)n_exp_d_col[i]);
}
