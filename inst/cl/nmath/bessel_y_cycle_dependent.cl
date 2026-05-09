// @source_type: c
// @source_origin: bessel_y_cycle_dependent.c
// @includes: nmath.h, bessel.h, refactored.h
// @depends: bessel_j_cycle_free, cospi, nmath, bessel, refactored
// @provides: bessel_y_cycle_dependent, bessel_y_cycle_dependent_ex
// @all_depends_count: 8
// @all_depends: bessel, refactored, Rmath, nmath, cospi, fmax2, gamma_cody, bessel_j_cycle_free
// @load_order: 70

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "bessel.h"
// openclport-disabled-include: #include "refactored.h"

/*
 * Draft cycle-dependent layer for bessel_y:
 * - for alpha < 0, returns only the cross-term that depends on bessel_j
 * - calls only the OTHER function's cycle_free path.
 */

double bessel_y_cycle_dependent(double x, double alpha)
{
    double na = floor(alpha);
    if (alpha >= 0) {
        return 0.0;
    }
    return ((alpha == na) ? 0 : bessel_j_cycle_free(x, -alpha) * sinpi(alpha));
}

double bessel_y_cycle_dependent_ex(double x, double alpha, double *by)
{
    double na = floor(alpha);
    if (alpha >= 0) {
        return 0.0;
    }
    return ((alpha == na) ? 0 : bessel_j_cycle_free_ex(x, -alpha, by) * sinpi(alpha));
}
