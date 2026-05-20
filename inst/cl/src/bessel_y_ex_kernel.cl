// @library_deps: nmath
// @depends_nmath: bessel_y
// @all_depends_nmath_count: 11
// @all_depends_nmath: bessel, refactored, Rmath, nmath, cospi, fmax2, gamma_cody, bessel_j_cycle_free, bessel_y_cycle_dependent, bessel_y_cycle_free, bessel_y

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_y_ex_kernel(
    __global const double* xv,
    __global const double* nu_col,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    double work = 0.0;
    out[i] = bessel_y_ex(xv[i], nu_col[i], &work);
}
