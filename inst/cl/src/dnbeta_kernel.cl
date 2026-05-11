#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dnbeta_kernel(
    const double x,
    const double a,
    const double ncp,
    const double b,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dnbeta(x, a, b, ncp, 0);
}
