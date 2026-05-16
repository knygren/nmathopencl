// @library_deps: nmath
// @depends_nmath: dexp
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dexp_kernel(
    const double x,
    const double rate,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dexp(x, rate, 0);
}
