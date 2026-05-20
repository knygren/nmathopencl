// @library_deps: nmath
// @depends_nmath: rnbinom
// @all_depends_nmath_count: 18
// @all_depends_nmath: dpq, Rmath, sunif, nmath, sexp, chebyshev, fmax2, fmin2, fsign, imax2, imin2, log1p, qnorm, snorm, expm1, rgamma, rpois, rnbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rnbinom_kernel(
    const double size,
    const double prob,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rnbinom(size, prob);
}
