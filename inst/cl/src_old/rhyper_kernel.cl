#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rhyper_kernel(
    const double r,
    const double b,
    const double n1,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = rhyper(r, b, n1);
}
