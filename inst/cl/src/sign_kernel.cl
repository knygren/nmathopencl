// @library_deps: nmath
// @depends_nmath: sign
// @all_depends_nmath_count: 3
// @all_depends_nmath: Rmath, nmath, sign

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void sign_kernel(
    const double x,
    const double unused_b,
    const double unused_c,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_b; (void)unused_c; (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = sign(x);
}
