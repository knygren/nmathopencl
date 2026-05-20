// @library_deps: nmath
// @depends_nmath: wilcox
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, log1p, gamma, lgamma, lbeta, choose, wilcox

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dwilcox_kernel(
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
