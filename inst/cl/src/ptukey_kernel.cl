#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void ptukey_kernel(
    const double q,
    const double nmeans,
    const double df,
    const double nranges,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = ptukey(q, nmeans, df, nranges, 1, 0);
}
