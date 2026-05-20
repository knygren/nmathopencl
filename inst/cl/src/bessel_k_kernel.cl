// @library_deps: nmath
// @depends_nmath: bessel_k
// @all_depends_nmath_count: 4
// @all_depends_nmath: bessel, Rmath, nmath, bessel_k

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_k_kernel_temp(
    __global const double* xv,
    __global const double* nu_col,
    __global const double* expo_scaled,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = bessel_k(xv[i], nu_col[i], expo_scaled[i]);
}
