// @library_deps: nmath
// @depends_nmath: sexp
// @all_depends_nmath_count: 4
// @all_depends_nmath: Rmath, sunif, nmath, sexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void exp_rand_kernel(
    const double a,
    const double b,
    const double index_upper,
    __global double* out,
    const int n
) {
    (void)a; (void)b; (void)index_upper;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) out[i] = exp_rand();
}
