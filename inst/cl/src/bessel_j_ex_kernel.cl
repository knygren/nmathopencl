// @library_deps: nmath
// @depends_nmath: bessel_j
// @all_depends_nmath_count: 11
// @all_depends_nmath: bessel, refactored, Rmath, nmath, cospi, fmax2, gamma_cody, bessel_j_cycle_free, bessel_y_cycle_free, bessel_j_cycle_dependent, bessel_j

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_j_ex_kernel(
    const double x,
    const double nu,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        double work = 0.0;
        out[i] = bessel_j_ex(x, nu, &work);
    }
}

__kernel void bessel_j_ex_kernel_temp(
    __global const double* xv,
    __global const double* nu_col,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    double work = 0.0;
    out[i] = bessel_j_ex(xv[i], nu_col[i], &work);
}
