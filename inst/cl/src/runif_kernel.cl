// runif_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif.c globals.

// @library_deps: nmath
// @depends_nmath: runif
// @all_depends_nmath_count: 4
// @all_depends_nmath: Rmath, sunif, nmath, runif

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void runif_kernel(
    const double a,
    const double b,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = runif(a, b);
    }
}


// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void runif_kernel_temp(
    const double a,
    const double b,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = runif(a, b);
    }
}
