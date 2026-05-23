// @library_deps: nmath
// @depends_nmath: bessel_j
// @all_depends_nmath_count: 11
// @all_depends_nmath: bessel, refactored, Rmath, nmath, cospi, fmax2, gamma_cody, bessel_j_cycle_free, bessel_y_cycle_free, bessel_j_cycle_dependent, bessel_j

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_j_kernel(
    __global const double* xv,
    __global const double* nu_col,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = bessel_j(xv[i], nu_col[i]);
}
