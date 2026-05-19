// @library_deps: nmath
// @depends_nmath: rcauchy
// @all_depends_nmath_count: 4
// @all_depends_nmath: Rmath, sunif, nmath, rcauchy

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rcauchy_kernel(
    const double location,
    const double scale,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rcauchy(location, scale);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rcauchy_kernel_temp(
    const double location,
    const double scale,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rcauchy(location, scale);
}
