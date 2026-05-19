// @library_deps: nmath
// @depends_nmath: qexp
// @all_depends_nmath_count: 11
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, pnorm, qnorm, gamma, lgammacor, qexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qexp_kernel_temp(
    __global const double* p,
    __global const double* rate,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qexp(p[i], rate[i], lt, lp);
}
