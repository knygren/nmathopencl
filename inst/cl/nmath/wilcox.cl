// @source_type: c
// @source_origin: wilcox.c
// @includes: Rmath.h, nmath.h, dpq.h, Utils.h
// @depends: choose, imax2, r_check_user_interrupt, sunif, Rmath, nmath, dpq
// @provides: dwilcox, pwilcox, qwilcox, rwilcox, wilcox_free
// @all_depends_count: 17
// @all_depends: dpq, refactored, Rmath, sunif, nmath, r_check_user_interrupt, stirlerr_cycle_free, chebyshev, cospi, fmax2, gammalims, imax2, lgammacor, gamma, lgamma, lbeta, choose
// @load_order: 103

/*
  Mathlib : A C Library of Special Functions
  Copyright (C) 1999-2024  The R Core Team

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at
  your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, a copy is available at
  https://www.R-project.org/Licenses/

  SYNOPSIS

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
    // openclport-disabled-include: #include <Rmath.h>
    double dwilcox(double x, double m, double n, int give_log)
    double pwilcox(double x, double m, double n, int lower_tail, int log_p)
    double qwilcox(double x, double m, double n, int lower_tail, int log_p);
    double rwilcox(double m, double n)

  DESCRIPTION

    dwilcox	The density of the Wilcoxon distribution.
    pwilcox	The distribution function of the Wilcoxon distribution.
    qwilcox	The quantile function of the Wilcoxon distribution.
    rwilcox	Random variates from the Wilcoxon distribution.

 */

/*
   Note: the checks here for R_CheckUserInterrupt also do stack checking.

   calloc/free are remapped for use in R, so allocation checks are done there.
   freeing is completed by an on.exit action in the R wrappers.
*/

// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

// openclport-disabled-include: #include <R_ext/Utils.h>

static double ***wilcox_w; /* to store  cwilcox(i,j,k) -> wilcox_w[i][j][k] */
static int wilcox_allocated_m, wilcox_allocated_n;

static void
wilcox_w_free(int m, int n)
{
    int i, j;

    for (i = m; i >= 0; i--) {
	for (j = n; j >= 0; j--) {
	    if (wilcox_w[i][j] != 0)
		free((void *) wilcox_w[i][j]);
	}
	free((void *) wilcox_w[i]);
    }
    free((void *) wilcox_w);
    wilcox_w = 0; wilcox_allocated_m = wilcox_allocated_n = 0;
}

static void
wilcox_w_init_maybe(int m, int n)
{
    int i;

    if (m > n) {
	i = n; n = m; m = i;
    }
    if (wilcox_w && (m > wilcox_allocated_m || n > wilcox_allocated_n))
	wilcox_w_free(wilcox_allocated_m, wilcox_allocated_n); /* zeroes wilcox_w */

    if (!wilcox_w) { /* initialize wilcox_w[][] */
	m = imax2(m, WILCOX_MAX);
	n = imax2(n, WILCOX_MAX);
	wilcox_w = (double ***) calloc((size_t) m + 1, sizeof(double **));
	for (i = 0; i <= m; i++) {
	    wilcox_w[i] = (double **) calloc((size_t) n + 1, sizeof(double *));
	}
	wilcox_allocated_m = m; wilcox_allocated_n = n;
    }
}

static void
wilcox_w_free_maybe(int m, int n)
{
    if (m > WILCOX_MAX || n > WILCOX_MAX)
	wilcox_w_free(m, n);
}


static int wilcox_ic = 99999;
/* This counts the number of choices with statistic = k */
static double
cwilcox(int k, int m, int n)
{
    int c, i, j,
	u = m * n;
    if (k < 0 || k > u)
	return(0);
    c = (int)(u / 2);
    if (k > c)
	k = u - k; /* hence  k <= floor(u / 2) */
    if (m < n) {
	i = m; j = n;
    } else {
	i = n; j = m;
    } /* hence  i <= j */

    if (j == 0) /* and hence i == 0 */
	return (k == 0);


    /* We can simplify things if k is small.  Consider the Mann-Whitney
       definition, and sort y.  Then if the statistic is k, no more
       than k of the y's can be <= any x[i], and since they are sorted
       these can only be in the first k.  So the count is the same as
       if there were just k y's.
    */
    if (j > 0 && k < j) return cwilcox(k, i, k);

    if (!wilcox_ic--) {
	R_CheckUserInterrupt();
	wilcox_ic = 99999;
    }

    if (wilcox_w[i][j] == 0) {
	wilcox_w[i][j] = (double *) calloc((size_t) c + 1, sizeof(double));
	for (int l = 0; l <= c; l++)
	    wilcox_w[i][j][l] = -1;
    }
    if (wilcox_w[i][j][k] < 0) {
	if (j == 0) /* and hence i == 0 */
	    wilcox_w[i][j][k] = (k == 0);
	else
	    wilcox_w[i][j][k] = cwilcox(k - j, i - 1, j) + cwilcox(k, i, j - 1);

    }
    return(wilcox_w[i][j][k]);
}

double dwilcox(double x, double m, double n, int give_log)
{
#ifdef IEEE_754
    /* NaNs propagated correctly */
    if (ISNAN(x) || ISNAN(m) || ISNAN(n))
	return(x + m + n);
#endif
    m = R_forceint(m);
    n = R_forceint(n);
    if (m <= 0 || n <= 0)
	ML_WARN_return_NAN;

    if (R_nonint(x))
	return(R_D__0);
    x = R_forceint(x);
    if ((x < 0) || (x > m * n))
	return(R_D__0);

    int mm = (int) m, nn = (int) n, xx = (int) x;
    wilcox_w_init_maybe(mm, nn);
    double d = give_log ?
	log(cwilcox(xx, mm, nn)) - lchoose(m + n, n) :
	    cwilcox(xx, mm, nn)  /  choose(m + n, n);

    return(d);
}

/* args have the same meaning as R function pwilcox */
double pwilcox(double q, double m, double n, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(q) || ISNAN(m) || ISNAN(n))
	return(q + m + n);
#endif
    if (!R_FINITE(m) || !R_FINITE(n))
	ML_WARN_return_NAN;
    m = R_forceint(m);
    n = R_forceint(n);
    if (m <= 0 || n <= 0)
	ML_WARN_return_NAN;

    q = floor(q + 1e-7);

    if (q < 0.0)
	return(R_DT_0);
    if (q >= m * n)
	return(R_DT_1);

    int mm = (int) m, nn = (int) n;
    wilcox_w_init_maybe(mm, nn);
    double c = choose(m + n, n),
	p = 0;
    /* Use summation of probs over the shorter range */
    if (q <= (m * n / 2)) {
	for (int i = 0; i <= q; i++)
	    p += cwilcox(i, mm, nn) / c;
    }
    else {
	q = m * n - q;
	for (int i = 0; i < q; i++)
	    p += cwilcox(i, mm, nn) / c;
	lower_tail = !lower_tail; /* p = 1 - p; */
    }

    return(R_DT_val(p));
} /* pwilcox */

/* x is 'p' in R function qwilcox */

double qwilcox(double x, double m, double n, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(m) || ISNAN(n))
	return(x + m + n);
#endif
    if(!R_FINITE(x) || !R_FINITE(m) || !R_FINITE(n))
	ML_WARN_return_NAN;
    R_Q_P01_check(x);

    m = R_forceint(m);
    n = R_forceint(n);
    if (m <= 0 || n <= 0)
	ML_WARN_return_NAN;

    if (x == R_DT_0)
	return(0);
    if (x == R_DT_1)
	return(m * n);

    if(log_p || !lower_tail)
	x = R_DT_qIv(x); /* lower_tail,non-log "p" */

    int mm = (int) m, nn = (int) n;
    wilcox_w_init_maybe(mm, nn);
    double c = choose(m + n, n),
	p = 0.;
    int q = 0;
    if (x <= 0.5) {
	x = x - 10 * DBL_EPSILON;
	for (;;) {
	    p += cwilcox(q, mm, nn) / c;
	    if (p >= x)
		break;
	    q++;
	}
    }
    else {
	x = 1 - x + 10 * DBL_EPSILON;
	for (;;) {
	    p += cwilcox(q, mm, nn) / c;
	    if (p > x) {
		q = (int) (m * n - q);
		break;
	    }
	    q++;
	}
    }

    return(q);
}

double rwilcox(double m, double n)
{
    int i, j, k, *x;
    double r;

#ifdef IEEE_754
    /* NaNs propagated correctly */
    if (ISNAN(m) || ISNAN(n))
	return(m + n);
#endif
    m = R_forceint(m);
    n = R_forceint(n);
    if ((m < 0) || (n < 0))
	ML_WARN_return_NAN;

    if ((m == 0) || (n == 0))
	return(0);

    r = 0.0;
    k = (int) (m + n);
    x = (int *) calloc((size_t) k, sizeof(int));
    for (i = 0; i < k; i++)
	x[i] = i;
    for (i = 0; i < n; i++) {
	j = (int) R_unif_index(k);
	r += x[j];
	x[j] = x[--k];
    }
    free(x);
    return(r - n * (n - 1) / 2);
}

void wilcox_free(void)
{
    wilcox_w_free_maybe(wilcox_allocated_m, wilcox_allocated_n);
}
