#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void r_check_user_interrupt_kernel(
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        R_CheckUserInterrupt();
        out[i] = (double)(i + 1);
    }
}
