#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnt_kernel(
    const double x,
    const double df,
    const double ncp,
    const double unused_df2,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_df2; (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dnt(x, df, ncp, 0);
}
