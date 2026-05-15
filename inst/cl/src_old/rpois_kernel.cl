#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rpois_kernel(
    const double unused_size,
    const double unused_prob,
    const double unused_lambda_p,
    const double lambda,
    __global double* out,
    const int n
) {
    (void)unused_size; (void)unused_prob; (void)unused_lambda_p;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rpois(lambda);
}
