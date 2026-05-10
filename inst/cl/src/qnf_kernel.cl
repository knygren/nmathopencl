#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnf_kernel(
    const double unused_x,
    const double df1,
    const double ncp,
    const double df2,
    const double p,
    __global double* out,
    const int n
) {
    (void)unused_x;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnf(p, df1, df2, ncp, 1, 0);
}
