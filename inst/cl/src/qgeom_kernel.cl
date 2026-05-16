// @library_deps: nmath
// @depends_nmath: qgeom
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qgeom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qgeom_kernel(
    const double p,
    const double prob,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qgeom(p, prob, 1, 0);
}
