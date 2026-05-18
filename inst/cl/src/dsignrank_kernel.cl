// @library_deps: nmath
// @depends_nmath: signrank
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2, signrank

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dsignrank_kernel(
    const double x,
    const double nsize,
    const double give_log_d,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dsignrank(x, nsize, give_log);
}

__kernel void dsignrank_kernel_temp(
    __global const double* x,
    __global const double* nsize,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dsignrank(x[i], nsize[i], gl);
}
