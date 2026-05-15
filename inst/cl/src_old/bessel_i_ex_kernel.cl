#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void bessel_i_ex_kernel(
    const double x,
    const double nu,
    const double expo,
    const double unused_d,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_d; (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        double work = 0.0;
        out[i] = bessel_i_ex(x, nu, expo, &work);
    }
}
