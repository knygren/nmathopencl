// @library_deps: nmath
// @depends_nmath: dlnorm
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dlnorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dlnorm_kernel(
    const double x,
    const double meanlog,
    const double sdlog,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dlnorm(x, meanlog, sdlog, 0);
}
