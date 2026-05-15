// @source_type: c
// @source_origin: dnf.c
// @includes: nmath.h, dpq.h
// @depends: dgamma, dnbeta, dnchisq, log1p, nmath, dpq
// @provides: dnf
// @all_depends_count: 26
// @all_depends: dpq, refactored, Rmath, nmath, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, lgammacor, log1p, gamma, lgamma, pgamma_utils, stirlerr_cycle_dependent, bd0, lbeta, stirlerr, dbinom, dpois, dbeta, dgamma, dnbeta, df, dchisq, dnchisq
// @load_order: 136

/*
 *  AUTHOR
 *    Peter Ruckdeschel, peter.ruckdeschel@uni-bayreuth.de.
 *    April 13, 2006.
 *
 *  Merge in to R:
 *	Copyright (C) 2006 The R Core Team
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
 *	The density function of the non-central F distribution ---
 *  obtained by differentiating the corresp. cumulative distribution function
 *  using dnbeta.
 *  For df1 < 2, since the F density has a singularity as x -> Inf.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double dnf(double x, double df1, double df2, double ncp, int give_log)
{
    double y, z, f;

#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(df1) || ISNAN(df2) || ISNAN(ncp))
	return x + df2 + df1 + ncp;
#endif

    /* want to compare dnf(ncp=0) behavior with df() one, hence *NOT* :
     * if (ncp == 0)
     *   return df(x, df1, df2, give_log); */

    if (df1 <= 0. || df2 <= 0. || ncp < 0) ML_WARN_return_NAN;
    if (x < 0.)	 return(R_D__0);
    if (!R_FINITE(ncp)) /* ncp = +Inf -- FIXME?: in some cases, limit exists */
	ML_WARN_return_NAN;

    /* This is not correct for  df1 == 2, ncp > 0 - and seems unneeded:
     *  if (x == 0.) return(df1 > 2 ? R_D__0 : (df1 == 2 ? R_D__1 : ML_POSINF));
     */
    if (!R_FINITE(df1) && !R_FINITE(df2)) { /* both +Inf */
	/* PR: not sure about this (taken from  ncp==0)  -- FIXME ? */
	if(x == 1.) return ML_POSINF; else return R_D__0;
    }
    if (!R_FINITE(df2)) /* i.e.  = +Inf */
	return df1* dnchisq(x*df1, df1, ncp, give_log);
    /*	 ==  dngamma(x, df1/2, 2./df1, ncp, give_log)  -- but that does not exist */
    if (df1 > 1e14 && ncp < 1e7) {
	/* includes df1 == +Inf: code below is inaccurate there */
	f = 1 + ncp/df1; /* assumes  ncp << df1 [ignores 2*ncp^(1/2)/df1*x term] */
	z = dgamma(1./x/f, df2/2, 2./df2, give_log);
	return give_log ? z - 2*log(x) - log(f) : z / (x*x) / f;
    }

    y = (df1 / df2) * x;
    z = dnbeta(y/(1 + y), df1 / 2., df2 / 2., ncp, give_log);
    return  give_log ?
	z + log(df1) - log(df2) - 2 * log1p(y) :
	z * (df1 / df2) /(1 + y) / (1 + y);
}



