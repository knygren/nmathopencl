// @library_deps: nmath
// @depends_nmath: rpois
// @all_depends_nmath_count: 15
// @all_depends_nmath: dpq, Rmath, sunif, nmath, sexp, chebyshev, fmax2, fmin2, fsign, imax2, imin2, log1p, qnorm, snorm, rpois

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rpois_kernel(
    const double unused_size,
    const double unused_prob,
    const double unused_lambda_p,
    const double lambda,
    __global double* out,
    const int n
) {
    (void)unused_size; (void)unused_prob; (void)unused_lambda_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rpois(lambda);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rpois_kernel_temp(
    const double unused_size,
    const double unused_prob,
    const double unused_lambda_p,
    const double lambda,
    __global double* out,
    const int n
) {
    (void)unused_size; (void)unused_prob; (void)unused_lambda_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rpois(lambda);
}
