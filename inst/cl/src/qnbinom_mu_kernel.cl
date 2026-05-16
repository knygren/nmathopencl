// @library_deps: nmath
// @depends_nmath: qnbinom_mu
// @all_depends_nmath_count: 10
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search, qpois, qnbinom_mu

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_mu_kernel(
    const double size,
    const double unused_prob,
    const double p,
    const double mu,
    __global double* out,
    const int n
) {
    (void)unused_prob;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbinom_mu(p, size, mu, 1, 0);
}
