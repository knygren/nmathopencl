// @library_deps: nmath
// @depends_nmath: plnorm
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, pnorm, plnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void plnorm_kernel(
    __global const double* q,
    __global const double* meanlog,
    __global const double* sdlog,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = plnorm(q[i], meanlog[i], sdlog[i], lt, lp);
}
