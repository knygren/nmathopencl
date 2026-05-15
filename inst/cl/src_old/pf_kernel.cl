#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pf_kernel(
    const double x,
    const double df1,
    const double df2,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pf(x, df1, df2, 1, 0);
}
