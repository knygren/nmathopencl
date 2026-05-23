// @library_deps: nmath
// @depends_nmath: qwilcox
// @all_depends_nmath_count: 37
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, stirlerr_cycle_free, chebyshev, fprec, fround, dnorm, fmax2, fmin2, lgamma_sim, pchisq, qnorm, stirlerr, dt, pchisq, pt, qwilcox, wilcox_free

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qwilcox_kernel(
    __global const double* p,
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
    out[i] = qwilcox(p[i], m[i], n2[i], lt, lp);
}
