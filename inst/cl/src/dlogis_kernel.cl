// @library_deps: nmath
// @depends_nmath: dlogis
// @all_depends_nmath_count: 4
// @all_depends_nmath: dpq, Rmath, nmath, dlogis

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dlogis_kernel(
    const double x,
    const double location,
    const double scale,
    const double give_log_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    const int give_log = (give_log_d != 0.0) ? 1 : 0;
    for (int i = 0; i < n; ++i) out[i] = dlogis(x, location, scale, give_log);
}

__kernel void dlogis_kernel_temp(
    __global const double* x,
    __global const double* location,
    __global const double* scale,
    __global const int* give_log,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    int gl = (give_log[i] != 0) ? 1 : 0;
    out[i] = dlogis(x[i], location[i], scale[i], gl);
}
