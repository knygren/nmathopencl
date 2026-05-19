// @library_deps: nmath
// @depends_nmath: wilcox
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, log1p, gamma, lgamma, lbeta, choose, wilcox

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pwilcox_kernel_temp(
    __global const double* q,
    __global const double* m,
    __global const double* n2,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = pwilcox(q[i], m[i], n2[i], lt, lp);
}
