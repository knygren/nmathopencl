// @library_deps: nmath
// @depends_nmath: qcauchy
// @all_depends_nmath_count: 8
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, cospi, log1p, expm1, qcauchy

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qcauchy_kernel(
    const double p,
    const double location,
    const double scale,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qcauchy(p, location, scale, 1, 0);
}
