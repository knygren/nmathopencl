// rwilcox_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif globals.

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rwilcox_kernel(
    const double m,
    const double n2,
    __global double* out,
    const int n_out
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n_out; ++i) {
        out[i] = rwilcox(m, n2);
    }
}
