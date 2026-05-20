// @library_deps: nmath
// @depends_nmath: plogis
// @all_depends_nmath_count: 6
// @all_depends_nmath: dpq, Rmath, nmath, chebyshev, log1p, plogis

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void log1pexp_kernel(
    __global const double* x,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    out[i] = log1pexp(x[i]);
}
