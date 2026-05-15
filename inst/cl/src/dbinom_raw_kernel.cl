// @library_deps: nmath
// @calls_nmath: dbinom_raw
// @depends_nmath: dbinom

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dbinom_raw_kernel(
    const double x,
    const double n_size,
    const double prob,
    const double qprob,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = dbinom_raw(x, n_size, prob, qprob, 0);
}
