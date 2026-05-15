#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void logspace_sub_kernel(
    const double logx,
    const double logy,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = logspace_sub(logx, logy);
    }
}
