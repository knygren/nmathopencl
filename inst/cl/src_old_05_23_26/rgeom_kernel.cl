// @library_deps: nmath
// @depends_nmath: rgeom
// @all_depends_nmath_count: 16
// @all_depends_nmath: dpq, Rmath, sunif, nmath, sexp, chebyshev, fmax2, fmin2, fsign, imax2, imin2, log1p, qnorm, snorm, rpois, rgeom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rgeom_kernel(
    const double prob,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rgeom(prob);
}
