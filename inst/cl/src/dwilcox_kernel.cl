// @library_deps: nmath
// @depends_nmath: wilcox
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, log1p, gamma, lgamma, lbeta, choose, wilcox

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dwilcox_kernel(
    const double x,
    const double m,
    const double n2,
    const double give_log_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dwilcox(x, m, n2, give_log);
}

__kernel void dwilcox_kernel_temp(
    __global const double* x,
    __global const double* m,
    __global const double* n2,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dwilcox(x[i], m[i], n2[i], gl);
}
