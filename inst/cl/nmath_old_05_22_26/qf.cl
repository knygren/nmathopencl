// @source_type: c
// @source_origin: qf.c
// @includes: nmath.h, dpq.h
// @depends: qbeta, qchisq, nmath, dpq
// @provides: qf
// @all_depends_count: 36
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pbeta, qbeta, qgamma, df, qchisq
// @load_order: 125

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 2000-2015 The R Core Team
 *  Copyright (C) 2005 The R Foundation
 *  Copyright (C) 1998 Ross Ihaka
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
 *    The quantile function of the F distribution.
*/

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double qf(double p, double df1, double df2, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(df1) || ISNAN(df2))
	return p + df1 + df2;
#endif
    if (df1 <= 0. || df2 <= 0.) ML_WARN_return_NAN;

    R_Q_P01_boundaries(p, 0, ML_POSINF);

    /* fudge the extreme DF cases -- qbeta doesn't do this well.
       But we still need to fudge the infinite ones.
     */

    if (df1 <= df2 && df2 > 4e5) {
	if(!R_FINITE(df1)) /* df1 == df2 == Inf : */
	    return 1.;
	/* else value for df2 == Inf : */
	return qchisq(p, df1, lower_tail, log_p) / df1;
    }
    else if (df1 > 4e5) { /* and so  df2 < df1 -- return value for df1 == Inf */
	return df2 / qchisq(p, df2, !lower_tail, log_p);
    }

    // FIXME: (1/qb - 1) = (1 - qb)/qb; if we know qb ~= 1, should use other tail
    p = (1. / qbeta(p, df2/2, df1/2, !lower_tail, log_p) - 1.) * (df2 / df1);
    return ML_VALID(p) ? p : ML_NAN;
}
