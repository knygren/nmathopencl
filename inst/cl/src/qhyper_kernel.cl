// @library_deps: nmath
// @depends_nmath: qhyper
// @all_depends_nmath_count: 17
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, fmin2, gammalims, lgammacor, log1p, gamma, lgamma, lbeta, choose, qhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qhyper_kernel_temp(
    __global const double* p,
    __global const double* r,
    __global const double* b,
    __global const double* n1,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qhyper(p[i], r[i], b[i], n1[i], lt, lp);
}
