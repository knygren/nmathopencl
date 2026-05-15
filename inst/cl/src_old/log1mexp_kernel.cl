#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void log1mexp_kernel(
    const double x,
    const double unused_y,
    const double unused_z,
    __global double* out,
    const int n
) {
    (void)unused_y;
    (void)unused_z;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = log1mexp(x);
    }
}
