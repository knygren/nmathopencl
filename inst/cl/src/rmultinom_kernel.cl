#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void rmultinom_kernel(
    const double size,
    const double prob,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    double pvec[2];
    int rN[2];
    pvec[0] = prob;
    pvec[1] = 1.0 - prob;
    for (int i = 0; i < n; ++i) {
        rmultinom((int)size, pvec, 2, rN);
        out[i] = (double)rN[0];
    }
}
