// @source_type: c
// @source_origin: qnbeta.c
// @includes: nmath.h, dpq.h
// @depends: fmin2, pnbeta, nmath, dpq
// @provides: qnbeta
// @all_depends_count: 29
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, d1mach, dnorm, fmax2, fmin2, gammalims, i1mach, lgammacor, log1p, pnorm, expm1, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, beta, dpois, pgamma, toms708, pnbeta
// @load_order: 115

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2006 The R Core Team
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

double qnbeta(double p, double a, double b, double ncp,
	      int lower_tail, int log_p)
{
    const static double accu = 1e-15;
    const static double Eps = 1e-14; /* must be > accu */

    double ux, lx, nx, pp;

#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(a) || ISNAN(b) || ISNAN(ncp))
	return p + a + b + ncp;
#endif
    if (!R_FINITE(a)) ML_WARN_return_NAN;

    if (ncp < 0. || a <= 0. || b <= 0.) ML_WARN_return_NAN;

    R_Q_P01_boundaries(p, 0, 1);

    p = R_DT_qIv(p);

    /* Invert pnbeta(.) :
     * 1. finding an upper and lower bound */
    if(p > 1 - DBL_EPSILON) return 1.0;
    pp = fmin2(1 - DBL_EPSILON, p * (1 + Eps));
    for(ux = 0.5;
	ux < 1 - DBL_EPSILON && pnbeta(ux, a, b, ncp, TRUE, FALSE) < pp;
	ux = 0.5*(1+ux));
    pp = p * (1 - Eps);
    for(lx = 0.5;
	lx > DBL_MIN && pnbeta(lx, a, b, ncp, TRUE, FALSE) > pp;
	lx *= 0.5);

    /* 2. interval (lx,ux)  halving : */
    do {
	nx = 0.5 * (lx + ux);
	if (pnbeta(nx, a, b, ncp, TRUE, FALSE) > p) ux = nx; else lx = nx;
    }
    while ((ux - lx) / nx > accu);

    return 0.5 * (ux + lx);
}
