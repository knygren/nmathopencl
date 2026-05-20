// rexp_kernel.cl
// Single-work-item RNG kernel to avoid shared-state races in sunif/sexp globals.

// @library_deps: nmath
// @depends_nmath: rexp
// @all_depends_nmath_count: 5
// @all_depends_nmath: Rmath, sunif, nmath, sexp, rexp

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

// NDRange-style name for host batch path (serial RNG: single gid==0 work-item).
__kernel void rexp_kernel(
    const double scale,
    __global double* out,
    const int n
) {
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        out[i] = rexp(scale);
    }
}
