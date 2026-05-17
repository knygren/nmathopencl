// @library_deps: nmath
// @depends_nmath: qlogis
// @all_depends_nmath_count: 26
// @all_depends_nmath: dpq, Rmath, nmath, stirlerr_cycle_free, chebyshev, fprec, lgammacor, log1p, dnorm, fmax2, pnorm, expm1, gamma, bd0, stirlerr_cycle_dependent, stirlerr, log1pmx, dpois, dnbinom_mu, dnchisq, qnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qlogis_kernel(
    const double p,
    const double location,
    const double scale,
    const double lower_tail_d,
    const double log_p_d,
    __global double* out,
    const int n
) {
    const int lt_i = (lower_tail_d != 0.0) ? 1 : 0;
    const int lp_i = (log_p_d != 0.0) ? 1 : 0;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qlogis(p, location, scale, lt_i, lp_i);
}
