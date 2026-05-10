#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pnbeta_kernel(
    const double x,
    const double a,
    const double ncp,
    const double b,
    const double unused_p,
    __global double* out,
    const int n
) {
    (void)unused_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pnbeta(x, a, b, ncp, 1, 0);
}
