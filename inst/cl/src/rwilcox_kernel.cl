// rwilcox_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif globals.

// @library_deps: nmath
// @depends_nmath: wilcox
// @all_depends_nmath_count: 19
// @all_depends_nmath: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, log1p, gamma, lgamma, lbeta, choose, wilcox

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rwilcox_kernel(
    const double m,
    const double n2,
    __global double* out,
    const int n_out
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n_out; ++i) {
        out[i] = rwilcox(m, n2);
    }
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rwilcox_kernel_temp(
    const double m,
    const double n2,
    __global double* out,
    const int n_out
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n_out; ++i) {
        out[i] = rwilcox(m, n2);
    }
}
