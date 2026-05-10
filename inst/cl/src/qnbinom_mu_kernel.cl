#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void qnbinom_mu_kernel(
    const double size,
    const double unused_prob,
    const double p,
    const double mu,
    __global double* out,
    const int n
) {
    (void)unused_prob;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = qnbinom_mu(p, size, mu, 1, 0);
}
