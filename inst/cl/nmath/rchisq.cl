// @source_type: c
// @source_origin: rchisq.c
// @includes: nmath.h
// @depends: df, rgamma, nmath
// @provides: rchisq
// @all_depends_count: 26
// @all_depends: dpq, refactored, Rmath, sunif, nmath, sexp, stirlerr_cycle_free, chebyshev, cospi, expm1, fmax2, fmin2, gammalims, lgammacor, snorm, gamma, lgamma, pgamma_utils, rgamma, stirlerr_cycle_dependent, bd0, stirlerr, dbinom, dpois, dgamma, df
// @load_order: 130

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000 The R Core Team
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
 *    double rchisq(double df);
 *
 *  DESCRIPTION
 *
 *    Random variates from the chi-squared distribution.
 *
 *  NOTES
 *
 *    Calls rgamma to do the real work.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"

double rchisq(double df)
{
    if (!R_FINITE(df) || df < 0.0) ML_WARN_return_NAN;

    return rgamma(df / 2.0, 2.0);
}
