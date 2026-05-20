// @library_deps: nmath
// @depends_nmath: df
// @all_depends_nmath_count: 21
// @all_depends_nmath: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void df_kernel(
    __global const double* x,
    __global const double* df1,
    __global const double* df2,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = df(x[i], df1[i], df2[i], gl);
}
