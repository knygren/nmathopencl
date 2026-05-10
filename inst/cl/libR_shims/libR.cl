// @source_type: shim
// @source_origin: libR
// @provides: R_pow, R_pow_di

/*
 * Minimal device-side libR runtime shim for OpenCL.
 * Keep this focused to symbols required by active kernel call paths.
 */

#ifndef OPENCLPORT_LIBR_SHIMS_LIBR_CL
#define OPENCLPORT_LIBR_SHIMS_LIBR_CL

INLINE double R_pow(double x, double y) {
    return pow(x, y);
}

INLINE double R_pow_di(double x, int n) {
    double p = 1.0;

    if (isnan(x)) return x;
    if (n != 0) {
        if (!isfinite(x)) return R_pow(x, (double)n);
        if (n < 0) { n = -n; x = 1.0 / x; }
        for (;;) {
            if (n & 1) p *= x;
            n >>= 1;
            if (!n) break;
            x *= x;
        }
    }
    return p;
}

#endif
