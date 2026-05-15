#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnf_kernel(
    const double x,
    const double df1,
    const double ncp,
    const double df2,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnf(x, df1, df2, ncp, 1, 0);
}
