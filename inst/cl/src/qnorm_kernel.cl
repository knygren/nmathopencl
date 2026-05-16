// @library_deps: nmath
// @depends_nmath: qnorm
// @all_depends_nmath_count: 6
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, qnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnorm_kernel(
    const double p,
    const double mu,
    const double sigma,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnorm(p, mu, sigma, 1, 0);
}
