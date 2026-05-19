// @library_deps: nmath
// @depends_nmath: snorm
// @all_depends_nmath_count: 10
// @all_depends_nmath: dpq, Rmath, sunif, nmath, chebyshev, fmax2, fmin2, log1p, qnorm, snorm

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void norm_rand_kernel(
    const double a,
    const double b,
    const double index_upper,
    __global double* out,
    const int n
) {
    (void)a; (void)b; (void)index_upper;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = norm_rand();
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void norm_rand_kernel_temp(
    const double a,
    const double b,
    const double index_upper,
    __global double* out,
    const int n
) {
    (void)a; (void)b; (void)index_upper;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = norm_rand();
}
