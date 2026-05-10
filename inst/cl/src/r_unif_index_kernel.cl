#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void r_unif_index_kernel(
    const double a,
    const double b,
    const double index_upper,
    __global double* out,
    const int n
) {
    (void)a; (void)b;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = R_unif_index(index_upper);
}
