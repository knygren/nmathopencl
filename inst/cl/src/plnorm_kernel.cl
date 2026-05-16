// @library_deps: nmath
// @depends_nmath: plnorm
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, pnorm, plnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void plnorm_kernel(
    const double q,
    const double meanlog,
    const double sdlog,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = plnorm(q, meanlog, sdlog, 1, 0);
}
