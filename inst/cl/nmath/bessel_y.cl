// @source_type: c
// @source_origin: bessel_y.c
// @includes: nmath.h, bessel.h, refactored.h
// @depends: bessel_y_cycle_dependent, bessel_y_cycle_free, cospi, nmath, bessel, refactored
// @provides: bessel_y, bessel_y_ex
// @all_depends_count: 10
// @all_depends: bessel, refactored, Rmath, nmath, cospi, fmax2, gamma_cody, bessel_j_cycle_free, bessel_y_cycle_dependent, bessel_y_cycle_free
// @load_order: 78

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "bessel.h"
// openclport-disabled-include: #include "refactored.h"

/*
 * Public wrapper for bessel_y:
 * - alpha < 0: self-term from cycle_free + cross-term from cycle_dependent
 * - alpha >= 0: cycle_free
 */

double bessel_y(double x, double alpha)
{
    double na = floor(alpha);
    if (alpha < 0) {
        return (((alpha - na == 0.5) ? 0 : bessel_y_cycle_free(x, -alpha) * cospi(alpha)) -
                bessel_y_cycle_dependent(x, alpha));
    }
    return bessel_y_cycle_free(x, alpha);
}

double bessel_y_ex(double x, double alpha, double *by)
{
    double na = floor(alpha);
    if (alpha < 0) {
        return (((alpha - na == 0.5) ? 0 : bessel_y_cycle_free_ex(x, -alpha, by) * cospi(alpha)) -
                bessel_y_cycle_dependent_ex(x, alpha, by));
    }
    return bessel_y_cycle_free_ex(x, alpha, by);
}
