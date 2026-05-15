// @source_type: c
// @source_origin: qpois.c
// @includes: nmath.h, dpq.h, qDiscrete_search.h
// @depends: fmax2, nmath, dpq, qDiscrete_search
// @provides: qpois
// @all_depends_count: 5
// @all_depends: dpq, qDiscrete_search, Rmath, nmath, fmax2
// @load_order: 55
// @local_macros: R_DBG_printf, R_DBG_printf, _thisDIST_, _dist_PARS_DECL_, _dist_PARS_, DO_SEARCH_

// openclport: macro hygiene pre-clean for concatenated translation units.
#ifdef R_DBG_printf
# undef R_DBG_printf
#endif
#ifdef _thisDIST_
# undef _thisDIST_
#endif
#ifdef _dist_PARS_DECL_
# undef _dist_PARS_DECL_
#endif
#ifdef _dist_PARS_
# undef _dist_PARS_
#endif
#ifdef DO_SEARCH_
# undef DO_SEARCH_
#endif

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1999-2021 The R Core Team
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
 *	The quantile function of the Poisson distribution.
 *
 *  METHOD
 *
 *	Uses the Cornish-Fisher Expansion to include a skewness
 *	correction to a normal approximation.  This gives an
 *	initial value which never seems to be off by more than
 *	1 or 2.	 A search is then conducted of values close to
 *	this initial start point.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

#ifdef DEBUG_qpois
# define R_DBG_printf(...) REprintf(__VA_ARGS__)
#else
# define R_DBG_printf(...)
#endif

#ifdef _thisDIST_
# undef _thisDIST_
#endif
#ifdef _dist_PARS_DECL_
# undef _dist_PARS_DECL_
#endif
#ifdef _dist_PARS_
# undef _dist_PARS_
#endif


#define _thisDIST_ pois
#define _dist_PARS_DECL_ double lambda
#define _dist_PARS_      lambda

// openclport-disabled-include: #include "qDiscrete_search.h"
//        ------------------>  do_search() and all called by q_DISCRETE_*() below

#if defined(__OPENCL_VERSION__) || defined(__OPENCL_C_VERSION__)
# ifdef DO_SEARCH_
#  undef DO_SEARCH_
# endif
# define DO_SEARCH_(Y_, incr_, ...) do_search_qpois(Y_, &z, p, __VA_ARGS__, incr_, lower_tail, log_p)

static double do_search_qpois(double y, double *z, double p, double lambda,
                              double incr, int lower_tail, int log_p)
{
    bool left = (lower_tail ? (*z >= p) : (*z < p));
    if(incr > 1) R_DBG_printf(", incr = %.0f\n", incr);
    else R_DBG_printf("\n");

    if(left) {
        for(int iter = 0; ; iter++) {
            double newz = -1.;
            if(iter % 10000 == 0) MAYBE_R_CheckUserInterrupt();
            if(y > 0) newz = P_DIST(y - incr, _dist_PARS_);
            else if(y < 0) y = 0;
            if(y == 0 || ISNAN(newz) || (lower_tail ? (newz < p) : (newz >= p))) {
                return y;
            }
            y = fmax2(0, y - incr);
            *z = newz;
        }
    } else {
        for(int iter = 0; ; iter++) {
            double prevy = y;
            double newz = -1.;
            if(iter % 10000 == 0) MAYBE_R_CheckUserInterrupt();
            y += incr;
            newz = P_DIST(y, _dist_PARS_);
            if(ISNAN(newz) || (lower_tail ? (newz >= p) : (newz < p))) {
                if (incr <= 1) {
                    *z = newz;
                    return y;
                }
                return prevy;
            }
            *z = newz;
        }
    }
}
#endif

double qpois(double p, double lambda, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(lambda))
	return p + lambda;
#endif
    if(!R_FINITE(lambda))
	ML_WARN_return_NAN;
    if(lambda < 0) ML_WARN_return_NAN;
    R_Q_P01_check(p);
    if(lambda == 0) return 0;
    if(p == R_DT_0) return 0;
    if(p == R_DT_1) return ML_POSINF;

    double
	mu = lambda,
	sigma = sqrt(lambda),
	// had gamma = sigma; PR#8058 should be skewness which is mu^-0.5 = 1/sigma
	gamma = 1.0/sigma;

     R_DBG_printf("qpois(p=%.12g, lambda=%.15g, l.t.=%d, log=%d):"
		  " mu=%g, sigma=%g, gamma=%g;\n",
		  p, lambda, lower_tail, log_p, mu, sigma, gamma);

     // never "needed" here (FIXME?):   q_DISCRETE_01_CHECKS();
     q_DISCRETE_BODY();
}

// openclport: macro hygiene post-clean for concatenated translation units.
#undef R_DBG_printf
#undef _thisDIST_
#undef _dist_PARS_DECL_
#undef _dist_PARS_
#undef DO_SEARCH_
