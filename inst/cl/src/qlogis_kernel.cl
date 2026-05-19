// @library_deps: nmath
// @depends_nmath: qlogis
// @all_depends_nmath_count: 26
// @all_depends_nmath: dpq, Rmath, nmath, stirlerr_cycle_free, chebyshev, fprec, lgammacor, log1p, dnorm, fmax2, pnorm, expm1, gamma, bd0, stirlerr_cycle_dependent, stirlerr, log1pmx, dpois, dnbinom_mu, dnchisq, qnbeta

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qlogis_kernel_temp(
    __global const double* p,
    __global const double* location,
    __global const double* scale,
    __global const int* lower_tail,
    __global const int* log_p,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int lt = (lower_tail[i] != 0) ? 1 : 0;
    int lp = (log_p[i] != 0) ? 1 : 0;
    out[i] = qlogis(p[i], location[i], scale[i], lt, lp);
}
