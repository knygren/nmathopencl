// @source_type: c
// @source_origin: dgeom.c
// @includes: nmath.h, dpq.h
// @depends: dbinom, nmath, dpq
// @provides: dgeom
// @all_depends_count: 17
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom
// @load_order: 92

/*
 *  AUTHOR
 *    Catherine Loader, catherine@research.bell-labs.com.
 *    October 23, 2000.
 *
 *  Merge in to R:
 *	Copyright (C) 2000-2014 The R Core Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 *
 *
 *  DESCRIPTION
 *
 *    Computes the geometric probabilities, Pr(X=x) = p(1-p)^x.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double dgeom(double x, double p, int give_log)
{ 
    double prob;

#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(p)) return x + p;
#endif

    if (p <= 0 || p > 1) ML_WARN_return_NAN;

    R_D_nonint_check(x);
    if (x < 0 || !R_FINITE(x) || p == 0) return R_D__0;
    x = R_forceint(x);

    /* prob = (1-p)^x, stable for small p */
    prob = dbinom_raw(0.,x, p,1-p, give_log);

    return((give_log) ? log(p) + prob : p*prob);
}
