// @library_deps: nmath
// @depends_nmath: r_check_user_interrupt
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, r_check_user_interrupt

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
