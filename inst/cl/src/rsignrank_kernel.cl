// @library_deps: nmath
// @depends_nmath: signrank
// @all_depends_nmath_count: 7
// @all_depends_nmath: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2, signrank

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rsignrank_kernel(
    const double nsize,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rsignrank(nsize);
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rsignrank_kernel_temp(
    const double nsize,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rsignrank(nsize);
}
