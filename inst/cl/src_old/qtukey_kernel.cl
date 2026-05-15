#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qtukey_kernel(
    const double p,
    const double nmeans,
    const double df,
    const double nranges,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qtukey(p, nmeans, df, nranges, 1, 0);
}
