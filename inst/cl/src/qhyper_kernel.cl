// @library_deps: nmath
// @depends_nmath: qhyper
// @all_depends_nmath_count: 17
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, fmin2, gammalims, lgammacor, log1p, gamma, lgamma, lbeta, choose, qhyper

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qhyper_kernel(
    const double p,
    const double r,
    const double b,
    const double n1,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qhyper(p, r, b, n1, 1, 0);
}
