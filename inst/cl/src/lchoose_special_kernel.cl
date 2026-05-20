// @library_deps: nmath
// @depends_nmath: choose
// @all_depends_nmath_count: 14
// @all_depends_nmath: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, lbeta, choose

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void lchoose_special_kernel_temp(
    __global const double* n_col,
    __global const double* kv,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = lchoose(n_col[i], kv[i]);
}
