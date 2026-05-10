#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void unif_rand_kernel(
    const double a,
    const double b,
    const double index_upper,
    __global double* out,
    const int n
) {
    (void)a; (void)b; (void)index_upper;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = unif_rand();
}
