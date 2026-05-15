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
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnorm(x, mu, sigma, 1, 0);
}
