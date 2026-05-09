// @source_type: c
// @source_origin: dnchisq.c
// @includes: nmath.h, dpq.h
// @depends: dchisq, df, dpois, nmath, dpq
// @provides: dnchisq
// @all_depends_count: 21
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df, dchisq
// @load_order: 135

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000-15 The R Core Team
 *  Copyright (C) 2004-15 The R Foundation
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 *
 *  DESCRIPTION
 *
 *    The density of the noncentral chi-squared distribution with "df"
 *    degrees of freedom and noncentrality parameter "ncp".
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double dnchisq(double x, double df, double ncp, int give_log)
{
    const static double eps = 5e-15;

    double i, ncp2, q, mid, dfmid, imax;
    LDOUBLE sum, term;

#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(df) || ISNAN(ncp))
	return x + df + ncp;
#endif

    if (!R_FINITE(df) || !R_FINITE(ncp) || ncp < 0 || df < 0)
    	ML_WARN_return_NAN;

    if(x < 0) return R_D__0;
    if(x == 0 && df < 2.)
	return ML_POSINF;
    if(ncp == 0)
	return (df > 0) ? dchisq(x, df, give_log) : R_D__0;
    if(x == ML_POSINF) return R_D__0;

    ncp2 = 0.5 * ncp;

    /* find max element of sum */
    imax = ceil((-(2+df) +sqrt((2-df) * (2-df) + 4 * ncp * x))/4);
    if (imax < 0) imax = 0;
    if(R_FINITE(imax)) {
	dfmid = df + 2 * imax;
	mid = dpois_raw(imax, ncp2, FALSE) * dchisq(x, dfmid, FALSE);
    } else /* imax = Inf */
	mid = 0;

    if(mid == 0) {
	/* underflow to 0 -- maybe numerically correct; maybe can be more accurate,
	 * particularly when  give_log = TRUE */
	/* Use  central-chisq approximation formula when appropriate;
	 * ((FIXME: the optimal cutoff also depends on (x,df);  use always here? )) */
	if(give_log || ncp > 1000.) {
	    double nl = df + ncp, ic = nl/(nl + ncp);/* = "1/(1+b)" Abramowitz & St.*/
	    return dchisq(x*ic, nl*ic, give_log);
	} else
	    return R_D__0;
    }

    sum = mid;

    /* errorbound := term * q / (1-q)  now subsumed in while() / if() below: */

    /* upper tail */
    term = mid; df = dfmid; i = imax;
    double x2 = x * ncp2;
    do {
	i++;
	q = x2 / i / df;
	df += 2;
	term *= q;
	sum += term;
    } while (q >= 1 || term * q > (1-q)*eps || term > 1e-10*sum);
    /* lower tail */
    term = mid; df = dfmid; i = imax;
    while (i != 0) {
	df -= 2;
	q = i * df / x2;
	i--;
	term *= q;
	sum += term;
	if (q < 1 && term * q <= (1-q)*eps) break;
    }
    return R_D_val((double) sum);
}
