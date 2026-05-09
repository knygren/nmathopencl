// @source_type: c
// @source_origin: ppois.c
// @includes: nmath.h, dpq.h
// @depends: pgamma, nmath, dpq
// @provides: ppois
// @all_depends_count: 19
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, expm1, fmax2, gammalims, lgammacor, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dpois, pgamma
// @load_order: 98

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000 The R Core Team
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
 *  DESCRIPTION
 *
 *    The distribution function of the Poisson distribution.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double ppois(double x, double lambda, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(lambda))
	return x + lambda;
#endif
    if(lambda < 0.) ML_WARN_return_NAN;
    if (x < 0)		return R_DT_0;
    if (lambda == 0.)	return R_DT_1;
    if (!R_FINITE(x))	return R_DT_1;
    x = floor(x + 1e-7);

    return pgamma(lambda, x + 1, 1., !lower_tail, log_p);
}
