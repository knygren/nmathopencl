// @source_type: c
// @source_origin: bessel_j_cycle_dependent.c
// @includes: nmath.h, bessel.h, refactored.h
// @depends: bessel_y_cycle_free, cospi, nmath, bessel, refactored
// @provides: bessel_j_cycle_dependent, bessel_j_cycle_dependent_ex
// @all_depends_count: 6
// @all_depends: bessel, refactored, Rmath, nmath, cospi, bessel_y_cycle_free
// @load_order: 77

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "bessel.h"
// openclport-disabled-include: #include "refactored.h"

/*
 * Draft cycle-dependent layer for bessel_j:
 * - for alpha < 0, returns only the cross-term that depends on bessel_y
 * - calls only the OTHER function's cycle_free path.
 */

double bessel_j_cycle_dependent(double x, double alpha)
{
    double na = floor(alpha);
    if (alpha >= 0) {
        return 0.0;
    }
    return ((alpha == na) ? 0 : bessel_y_cycle_free(x, -alpha) * sinpi(alpha));
}

double bessel_j_cycle_dependent_ex(double x, double alpha, double *bj)
{
    double na = floor(alpha);
    if (alpha >= 0) {
        return 0.0;
    }
    return ((alpha == na) ? 0 : bessel_y_cycle_free_ex(x, -alpha, bj) * sinpi(alpha));
}
