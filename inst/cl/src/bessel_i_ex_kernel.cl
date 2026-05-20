// @library_deps: nmath
// @depends_nmath: bessel_i
// @all_depends_nmath_count: 8
// @all_depends_nmath: bessel, Rmath, nmath, bessel_k, cospi, fmax2, gamma_cody, bessel_i

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_i_ex_kernel_temp(
    __global const double* xv,
    __global const double* nu_col,
    __global const double* expo,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    double work = 0.0;
    out[i] = bessel_i_ex(xv[i], nu_col[i], expo[i], &work);
}
