// @library_deps: nmath
// @depends_nmath: bessel_k
// @all_depends_nmath_count: 4
// @all_depends_nmath: bessel, Rmath, nmath, bessel_k

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_k_ex_kernel(
    __global const double* xv,
    __global const double* nu_col,
    __global const double* expo,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    double work = 0.0;
    out[i] = bessel_k_ex(xv[i], nu_col[i], expo[i], &work);
}
