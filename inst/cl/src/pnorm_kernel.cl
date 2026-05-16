// @library_deps: nmath
// @calls_nmath: pnorm5
// @depends_nmath: pnorm
// @all_depends_nmath_count: 6
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, pnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnorm_kernel(
    const double x,
    const double mu,
    const double sigma,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    int lt = (lower_tail_d != 0.0) ? 1 : 0;
    int lp = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnorm(x, mu, sigma, lt, lp);
}
