// @library_deps: nmath
// @depends_nmath: bessel_i
// @all_depends_nmath_count: 8
// @all_depends_nmath: bessel, Rmath, nmath, bessel_k, cospi, fmax2, gamma_cody, bessel_i

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_i_kernel(
    __global const double* xv,
    __global const double* nu_col,
    __global const double* expo_scaled,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = bessel_i(xv[i], nu_col[i], expo_scaled[i]);
}
