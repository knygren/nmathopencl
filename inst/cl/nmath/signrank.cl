// @source_type: c
// @source_origin: signrank.c
// @includes: nmath.h, dpq.h
// @depends: imin2, r_check_user_interrupt, sunif, nmath, dpq
// @provides: dsignrank, psignrank, qsignrank, rsignrank, signrank_free
// @all_depends_count: 6
// @all_depends: dpq, Rmath, sunif, nmath, r_check_user_interrupt, imin2
// @load_order: 59

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1999-2024  The R Core Team
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
 *    #include <Rmath.h>
 *    double dsignrank(double x, double n, int give_log)
 *    double psignrank(double x, double n, int lower_tail, int log_p)
 *    double qsignrank(double x, double n, int lower_tail, int log_p)
 *    double rsignrank(double n)
 *
 *  DESCRIPTION
 *
 *    dsignrank	   The density of the Wilcoxon Signed Rank distribution.
 *    psignrank	   The distribution function of the Wilcoxon Signed Rank
 *		   distribution.
 *    qsignrank	   The quantile function of the Wilcoxon Signed Rank
 *		   distribution.
 *    rsignrank	   Random variates from the Wilcoxon Signed Rank
 *		   distribution.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

static double *signrank_w;
static int signrank_allocated_n;

static void
signrank_w_free(void)
{
    if (!signrank_w) return;

    free((void *) signrank_w);
    signrank_w = 0;
    signrank_allocated_n = 0;
}

void signrank_free(void)
{
    signrank_w_free();
}

static void
signrank_w_init_maybe(int n)
{
    int u, c;

    u = n * (n + 1) / 2;
    c = (u / 2);

    if (signrank_w) {
        if(n != signrank_allocated_n) {
	    signrank_w_free();
	}
	else return;
    }

    if(!signrank_w) {
	signrank_w = (double *) calloc((size_t) c + 1, sizeof(double));
	signrank_allocated_n = n;
    }
}

static double
csignrank(int k, int n)
{
    int c, u, j;

    R_CheckUserInterrupt();

    u = n * (n + 1) / 2;
    c = (u / 2);

    if (k < 0 || k > u)
	return 0;
    if (k > c)
	k = u - k;

    if (n == 1)
        return 1.;
    if (signrank_w[0] == 1.)
        return signrank_w[k];

    signrank_w[0] = signrank_w[1] = 1.;
    for(j = 2; j < n+1; ++j) {
        int i, end = imin2(j*(j+1)/2, c);
	for(i = end; i >= j; --i)
	    signrank_w[i] += signrank_w[i-j];
    }

    return signrank_w[k];
}

double dsignrank(double x, double n, int give_log)
{
    double d;

#ifdef IEEE_754
    /* NaNs propagated correctly */
    if (ISNAN(x) || ISNAN(n)) return(x + n);
#endif
    n = R_forceint(n);
    if (n <= 0)
	ML_WARN_return_NAN;

    if (R_nonint(x))
	return(R_D__0);
    x = R_forceint(x);
    if ((x < 0) || (x > (n * (n + 1) / 2)))
	return(R_D__0);

    int nn = (int) n;
    signrank_w_init_maybe(nn);
    d = R_D_exp(log(csignrank((int) x, nn)) - n * M_LN2);

    return(d);
}

double psignrank(double x, double n, int lower_tail, int log_p)
{
    int i;
    double f, p;

#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(n))
    return(x + n);
#endif
    if (!R_FINITE(n)) ML_WARN_return_NAN;
    n = R_forceint(n);
    if (n <= 0) ML_WARN_return_NAN;

    x = R_forceint(x + 1e-7);
    if (x < 0.0)
	return(R_DT_0);
    if (x >= n * (n + 1) / 2)
	return(R_DT_1);

    int nn = (int) n;
    signrank_w_init_maybe(nn);
    f = exp(- n * M_LN2);
    p = 0;
    if (x <= (n * (n + 1) / 4)) {
	for (i = 0; i <= x; i++)
	    p += csignrank(i, nn) * f;
    }
    else {
	x = n * (n + 1) / 2 - x;
	for (i = 0; i < x; i++)
	    p += csignrank(i, nn) * f;
	lower_tail = !lower_tail; /* p = 1 - p; */
    }

    return(R_DT_val(p));
} /* psignrank() */

double qsignrank(double x, double n, int lower_tail, int log_p)
{
    double f, p;

#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(n))
	return(x + n);
#endif
    if (!R_FINITE(x) || !R_FINITE(n))
	ML_WARN_return_NAN;
    R_Q_P01_check(x);

    n = R_forceint(n);
    if (n <= 0)
	ML_WARN_return_NAN;

    if (x == R_DT_0)
	return(0);
    if (x == R_DT_1)
	return(n * (n + 1) / 2);

    if(log_p || !lower_tail)
	x = R_DT_qIv(x); /* lower_tail,non-log "p" */

    int nn = (int) n;
    signrank_w_init_maybe(nn);
    f = exp(- n * M_LN2);
    p = 0;
    int q = 0;
    if (x <= 0.5) {
	x = x - 10 * DBL_EPSILON;
	for (;;) {
	    p += csignrank(q, nn) * f;
	    if (p >= x)
		break;
	    q++;
	}
    }
    else {
	x = 1 - x + 10 * DBL_EPSILON;
	for (;;) {
	    p += csignrank(q, nn) * f;
	    if (p > x) {
		q = (int)(n * (n + 1) / 2 - q);
		break;
	    }
	    q++;
	}
    }

    return(q);
}

double rsignrank(double n)
{
    int i, k;
    double r;

#ifdef IEEE_754
    /* NaNs propagated correctly */
    if (ISNAN(n)) return(n);
#endif
    n = R_forceint(n);
    if (n < 0) ML_WARN_return_NAN;

    if (n == 0)
	return(0);
    r = 0.0;
    k = (int) n;
    for (i = 0; i < k; ) {
	r += (++i) * floor(unif_rand() + 0.5);
    }
    return(r);
}
