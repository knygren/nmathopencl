// @source_type: c
// @source_origin: qnbinom.c
// @includes: nmath.h, dpq.h, qDiscrete_search.h
// @depends: fmax2, nmath, dpq, qDiscrete_search
// @provides: qnbinom
// @all_depends_count: 5
// @all_depends: dpq, qDiscrete_search, Rmath, nmath, fmax2
// @load_order: 53
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
 *  Copyright (C) 2000-2021 The R Core Team
 *  Copyright (C) 2005-2021 The R Foundation
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
 *  SYNOPSIS
 *
 *	#include <Rmath.h>
 *	double qnbinom(double p, double size, double prob,
 *                     int lower_tail, int log_p)
 *
 *  DESCRIPTION
 *
 *	The quantile function of the negative binomial distribution,
 *      for the (size, prob) parametrizations
 *
 *  NOTES
 *
 *	x = the number of failures before the n-th success
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

/*-------- DEBUGGING ------------- 	make CFLAGS='-DDEBUG_qnbinom  ...'
 */
#ifdef DEBUG_qnbinom
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

#define _thisDIST_ nbinom
#define _dist_PARS_DECL_ double size, double prob
#define _dist_PARS_      size, prob

// openclport-disabled-include: #include "qDiscrete_search.h"
//        ------------------>  do_search() and all called by q_DISCRETE_*() below

#if defined(__OPENCL_VERSION__) || defined(__OPENCL_C_VERSION__)
# ifdef DO_SEARCH_
#  undef DO_SEARCH_
# endif
# define DO_SEARCH_(Y_, incr_, ...) do_search_qnbinom(Y_, &z, p, __VA_ARGS__, incr_, lower_tail, log_p)

static double do_search_qnbinom(double y, double *z, double p, double size, double prob,
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

double qnbinom(double p, double size, double prob, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(size) || ISNAN(prob))
	return p + size + prob;
#endif

    /* this happens if specified via mu, size, since
       prob == size/(size+mu)
    */
    if (prob == 0 && size == 0) return 0;
    if (prob <= 0 || prob > 1 || size < 0) ML_WARN_return_NAN;
    if (prob == 1 || size == 0) return 0;

    R_Q_P01_boundaries(p, 0, ML_POSINF);

    double
	Q = 1.0 / prob,
	P = (1.0 - prob) * Q, // = (1 - prob) / prob  =  Q - 1
	mu = size * P,
	sigma = sqrt(size * P * Q),
	gamma = (Q + P)/sigma;

    R_DBG_printf("qnbinom(p=%.12g, size=%.15g, prob=%g, l.t.=%d, log=%d):"
		 " mu=%g, sigma=%g, gamma=%g;\n",
		 p, size, prob, lower_tail, log_p, mu, sigma, gamma);

    q_DISCRETE_01_CHECKS();
    q_DISCRETE_BODY();
}

// openclport: macro hygiene post-clean for concatenated translation units.
#undef R_DBG_printf
#undef _thisDIST_
#undef _dist_PARS_DECL_
#undef _dist_PARS_
#undef DO_SEARCH_
