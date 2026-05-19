// @library_deps: nmath
// @depends_nmath: polygamma
// @all_depends_nmath_count: 8
// @all_depends_nmath: Rmath, nmath, d1mach, fmax2, fmin2, i1mach, imin2, polygamma

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void dpsifn_kernel(
    const double x,
    const double n_deriv,
    const double kode,
    const double m,
    const double unused_e,
    __global double* out,
    const int n
) {
    (void)unused_e; (void)m;
    if (get_global_id(0) != 0) return;
    for (int i = 0; i < n; ++i) {
        double ans[1];
        int nz = 0;
        int ierr = 0;
        dpsifn(x, (int)n_deriv, (int)kode, 1, ans, &nz, &ierr);
        out[i] = (ierr == 0) ? ans[0] : NAN;
    }
}

__kernel void dpsifn_kernel_temp(
    __global const double* xv,
    __global const double* n_deriv_col,
    __global const double* kode_col,
    __global const double* m_unused,
    __global double* out,
    const int len
) {
    int i = get_global_id(0);
    if (i >= len) return;
    (void)m_unused;
    double ans[1];
    int nz = 0;
    int ierr = 0;
    dpsifn(xv[i], (int)n_deriv_col[i], (int)kode_col[i], 1, ans, &nz, &ierr);
    out[i] = (ierr == 0) ? ans[0] : NAN;
}
