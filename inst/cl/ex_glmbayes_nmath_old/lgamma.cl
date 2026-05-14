// @source_type: c
// @source_origin: lgamma.c
// @includes: nmath.h
// @depends: cospi, gamma, lgammacor, nmath
// @provides: lgammafn_sign, lgammafn
// @all_depends_count: 10
// @all_depends: refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, gamma
// @load_order: 73
// @local_macros: xmax, dxrel

// openclport: macro hygiene pre-clean for concatenated translation units.
#ifdef xmax
# undef xmax
#endif
#ifdef dxrel
# undef dxrel
#endif

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 2000-2020 The R Core Team
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
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"

/* For IEEE double precision DBL_EPSILON = 2^-52 = 2.220446049250313e-16 :
   xmax  = DBL_MAX / log(DBL_MAX) = 2^1024 / (1024 * log(2)) = 2^1014 / log(2)
   dxrel = sqrt(DBL_EPSILON) = 2^-26 = 5^26 * 1e-26 (is *exact* below !)
*/
#define xmax  2.5327372760800758e+305
#define dxrel 1.490116119384765625e-8

double lgammafn_sign(double x, int *sgn)
{
    double ans, y, sinpiy;

    if (sgn != NULL) *sgn = 1;

#ifdef IEEE_754
    if(ISNAN(x)) return x;
#endif

    if (sgn != NULL && x < 0 && fmod(floor(-x), 2.) == 0)
	*sgn = -1;

    if (x <= 0 && x == trunc(x)) { /* Negative integer argument */
	return ML_POSINF;/* +Inf, since lgamma(x) = log|gamma(x)| */
    }

    y = fabs(x);

    if (y < 1e-306) return -log(y); // denormalized range, R change
    if (y <= 10) return log(fabs(gammafn(x)));

    if (y > xmax) {
	return ML_POSINF;
    }

    if (x > 0) { /* i.e. y = x > 10 */
#ifdef IEEE_754
	if(x > 1e17)
	    return(x*(log(x) - 1.));
	else if(x > 4934720.)
	    return(M_LN_SQRT_2PI + (x - 0.5) * log(x) - x);
	else
#endif
	    return M_LN_SQRT_2PI + (x - 0.5) * log(x) - x + lgammacor(x);
    }
    /* else: x < -10; y = -x */
    sinpiy = fabs(sinpi(y));

    if (sinpiy == 0) { /* Negative integer argument ===
			  Now UNNECESSARY: caught above */
	MATHLIB_WARNING(" ** should NEVER happen! *** [lgamma.c: Neg.int, y=%g]\n",y);
	ML_WARN_return_NAN;
    }

    ans = M_LN_SQRT_PId2 + (x - 0.5) * log(y) - x - log(sinpiy) - lgammacor(y);

    if(fabs((x - trunc(x - 0.5)) * ans / x) < dxrel) {

	/* The answer is less than half precision because
	 * the argument is too near a negative integer; e.g. for  lgamma(1e-7 - 11) */

	ML_WARNING(ME_PRECISION, "lgamma");
    }

    return ans;
}

double lgammafn(double x)
{
    return lgammafn_sign(x, NULL);
}

// openclport: macro hygiene post-clean for concatenated translation units.
#undef xmax
#undef dxrel
