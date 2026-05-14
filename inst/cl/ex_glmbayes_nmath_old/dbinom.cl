// @source_type: c
// @source_origin: dbinom.c
// @includes: nmath.h, dpq.h
// @depends: bd0, stirlerr, nmath, dpq
// @provides: pow1p, dbinom_raw, dbinom
// @all_depends_count: 16
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, stirlerr
// @load_order: 91

/*
 * AUTHOR
 *   Catherine Loader, catherine@research.bell-labs.com.
 *   October 23, 2000.
 *
 *  Merge in to R and further tweaks :
 *  notably using log1p() and pow1p(), thanks to Morten Welinder, PR#18642
 *
 *	Copyright (C) 2000-2025 The R Core Team
 *	Copyright (C) 2008 The R Foundation
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
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

/* Compute  (1+x)^y  accurately also for |x| << 1  */
double pow1p(double x, double y)
{
    if(isnan(y))
	return (x == 0) ? 1. : y;
    if(0 <= y && y == trunc(y) && y <= 4.) {
	switch((int)y) {
	case 0: return 1;
	case 1: return x + 1.;
	case 2: return x*(x + 2.) + 1.;
	case 3: return x*(x*(x + 3.) + 3.) + 1.;
	case 4: return x*(x*(x*(x + 4.) + 6.) + 4.) + 1.;
	}
    }
    volatile double xp1 = x + 1., x_ = xp1 - 1.;
    if (x_ == x || fabs(x) > 0.5 || isnan(x)) {
	return pow(xp1, y);
    } else {
	return exp(y * log1p(x));
    }
}

double dbinom_raw(double x, double n, double p, double q, int give_log)
{
    if (p == 0) return((x == 0) ? R_D__1 : R_D__0);
    if (q == 0) return((x == n) ? R_D__1 : R_D__0);

    if (x == 0) {
	if(n == 0) return R_D__1;
	if (p > q)
	    return give_log ? n * log(q)    : pow(q, n);
	else
	    return give_log ? n * log1p(-p) : pow1p(-p, n);
    }
    if (x == n) {
	if (p > q)
	    return give_log ? n * log1p(-q) : pow1p(-q, n);
	else
	    return give_log ? n * log (p)   : pow (p, n);
    }
    if (x < 0 || x > n) return( R_D__0 );

    if(!R_FINITE(n)) {
	if(R_FINITE(x)) return( R_D__0 );
	else n = DBL_MAX;
    }

    double lc = stirlerr(n) - stirlerr(x) - stirlerr(n-x) - bd0(x,n*p) - bd0(n-x,n*q);

    double lf = M_LN_2PI + log(x) + log1p(- x/n);

    return R_D_exp(lc - 0.5*lf);
}

double dbinom(double x, double n, double p, int give_log)
{
#ifdef IEEE_754
    /* NaNs propagated correctly */
    if (ISNAN(x) || ISNAN(n) || ISNAN(p)) return x + n + p;
#endif

    if (p < 0 || p > 1 || R_D_negInonint(n))
	ML_WARN_return_NAN;
    R_D_nonint_check(x);
    if (x < 0 || !R_FINITE(x)) return R_D__0;

    n = R_forceint(n);
    x = R_forceint(x);

    return dbinom_raw(x, n, p, 1-p, give_log);
}
