// @source_type: c
// @source_origin: qnf.c
// @includes: nmath.h, dpq.h
// @depends: qnbeta, qnchisq, nmath, dpq
// @provides: qnf
// @all_depends_count: 40
// @all_depends: dpq, refactored, Rmath, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, qnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dbinom, dpois, pgamma, toms708, dgamma, pnbeta, qgamma, qnbeta, df, pchisq, pnchisq, qchisq, qnchisq
// @load_order: 127

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2006-8 The R Core Team
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

double qnf(double p, double df1, double df2, double ncp, int lower_tail, 
	   int log_p)
{
    double y;
    
#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(df1) || ISNAN(df2) || ISNAN(ncp))
	return p + df1 + df2 + ncp;
#endif
    if (df1 <= 0. || df2 <= 0. || ncp < 0) ML_WARN_return_NAN;
    if (!R_FINITE(ncp)) ML_WARN_return_NAN;
    if (!R_FINITE(df1) && !R_FINITE(df2)) ML_WARN_return_NAN;
    R_Q_P01_boundaries(p, 0, ML_POSINF);

    if (df2 > 1e8) /* avoid problems with +Inf and loss of accuracy */
	return qnchisq(p, df1, ncp, lower_tail, log_p)/df1;

    y = qnbeta(p, df1 / 2., df2 / 2., ncp, lower_tail, log_p);
    return y/(1-y) * (df2/df1);
}
