// @library_deps: nmath
// @depends_nmath: qpois
// @all_depends_nmath_count: 9
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search, qpois

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qpois_kernel(
    const double unused_size,
    const double unused_prob,
    const double p,
    const double lambda,
    __global double* out,
    const int n
) {
    (void)unused_size; (void)unused_prob;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qpois(p, lambda, 1, 0);
}
