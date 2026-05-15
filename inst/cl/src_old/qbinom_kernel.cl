#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qbinom_kernel(
    const double size,
    const double prob,
    const double p,
    const double unused_mu,
    __global double* out,
    const int n
) {
    (void)unused_mu;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qbinom(p, size, prob, 1, 0);
}
