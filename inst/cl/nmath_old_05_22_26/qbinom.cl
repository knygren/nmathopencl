// @source_type: c
// @source_origin: qbinom.c
// @includes: nmath.h, dpq.h, qDiscrete_search.h
// @depends: fmax2, nmath, dpq, qDiscrete_search
// @provides: qbinom
// @all_depends_count: 8
// @all_depends: dpq, Rmath, nmath, chebyshev, fmax2, log1p, qnorm, qDiscrete_search
// @load_order: 80
// @local_macros: R_DBG_printf, R_DBG_printf, _thisDIST_, _dist_PARS_DECL_, _dist_PARS_, _dist_MAX_y, DO_SEARCH_

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
#ifdef _dist_MAX_y
# undef _dist_MAX_y
#endif
#ifdef DO_SEARCH_
# undef DO_SEARCH_
#endif

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1999-2021 The R Core Team
 *  Copyright (C) 2003-2021 The R Foundation
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
 *	The quantile function of the binomial distribution.
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

#ifdef DEBUG_qbinom
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
#ifdef _dist_MAX_y
# undef _dist_MAX_y
#endif


#define _thisDIST_ binom
#define _dist_PARS_DECL_ double n, double pr
#define _dist_PARS_      n, pr
#define _dist_MAX_y  n
//                  ===  Binomial  Y <= n

// openclport-disabled-include: #include "qDiscrete_search.h"
//        ------------------>  do_search() and all called by q_DISCRETE_*() below

#if defined(__OPENCL_VERSION__) || defined(__OPENCL_C_VERSION__)
# ifdef DO_SEARCH_
#  undef DO_SEARCH_
# endif
# define DO_SEARCH_(Y_, incr_, ...) do_search_qbinom(Y_, &z, p, __VA_ARGS__, incr_, lower_tail, log_p)

static double do_search_qbinom(double y, double *z, double p, double n, double pr,
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
#ifdef _dist_MAX_y
            if(y < _dist_MAX_y) newz = P_DIST(y, _dist_PARS_);
            else if(y > _dist_MAX_y) y = _dist_MAX_y;
#else
            newz = P_DIST(y, _dist_PARS_);
#endif
            if(
#ifdef _dist_MAX_y
                y == _dist_MAX_y ||
#endif
                ISNAN(newz) || (lower_tail ? (newz >= p) : (newz < p)))
            {
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

double qbinom(double p, double n, double pr, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(p) || ISNAN(n) || ISNAN(pr))
	return p + n + pr;
#endif
    if(!R_FINITE(n) || !R_FINITE(pr))
	ML_WARN_return_NAN;
    /* if log_p is true, p = -Inf is a legitimate value */
    if(!R_FINITE(p) && !log_p)
	ML_WARN_return_NAN;

    n = R_forceint(n);

    if (pr < 0 || pr > 1 || n < 0)
	ML_WARN_return_NAN;

    R_Q_P01_boundaries(p, 0, n);

    if (pr == 0. || n == 0) return 0.;
    if (pr == 1.)           return n; /* covers the full range of the distribution */

    // (NB: unavoidable cancellation for pr ~= 1)
    double
	q = 1 - pr,
	mu = n * pr,
	sigma = sqrt(n * pr * q),
	gamma = (q - pr) / sigma;

    R_DBG_printf("qbinom(p=%.12g, n=%.15g, pr=%.7g, l.t.=%d, log=%d): sigma=%g, gamma=%g;\n",
		 p, n,pr, lower_tail, log_p, sigma, gamma);

    q_DISCRETE_01_CHECKS();
    q_DISCRETE_BODY();
}

// openclport: macro hygiene post-clean for concatenated translation units.
#undef R_DBG_printf
#undef _thisDIST_
#undef _dist_PARS_DECL_
#undef _dist_PARS_
#undef _dist_MAX_y
#undef DO_SEARCH_
