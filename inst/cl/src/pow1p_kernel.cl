#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pow1p_kernel(
    const double x,
    const double y,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = pow1p(x, y);
    }
}
