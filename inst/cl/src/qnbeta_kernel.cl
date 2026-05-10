#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbeta_kernel(
    const double unused_x,
    const double a,
    const double ncp,
    const double b,
    const double p,
    __global double* out,
    const int n
) {
    (void)unused_x;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbeta(p, a, b, ncp, 1, 0);
}
