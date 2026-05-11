#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void pbinom_kernel(
    const double q,
    const double size,
    const double prob,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = pbinom(q, size, prob, 1, 0);
}
