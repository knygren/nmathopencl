#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnt_kernel(
    const double unused_x,
    const double df,
    const double ncp,
    const double unused_df2,
    const double p,
    __global double* out,
    const int n
) {
    (void)unused_x; (void)unused_df2;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnt(p, df, ncp, 1, 0);
}
