// @library_deps: nmath
// @depends_nmath: qnbinom
// @all_depends_nmath_count: 9
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search, qnbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_kernel(
    __global const double* p,
    __global const double* size,
    __global const double* prob,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qnbinom(p[i], size[i], prob[i], lt, lp);
}
