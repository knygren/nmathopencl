// @library_deps: nmath
// @calls_nmath: pnorm5
// @depends_nmath: pnorm
// @all_depends_nmath_count: 6
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, pnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// Indexed by work-item id (cf. ex_glmbayes f2_f3_* kernels).
__kernel void pnorm_kernel(
    __global const double* q,
    __global const double* mean,
    __global const double* sd,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = pnorm(q[i], mean[i], sd[i], lt, lp);
}
