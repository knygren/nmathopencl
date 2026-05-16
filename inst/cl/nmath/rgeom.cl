// @source_type: c
// @source_origin: rgeom.c
// @includes: nmath.h
// @depends: rpois, sexp, nmath
// @provides: rgeom
// @all_depends_count: 15
// @all_depends: dpq, Rmath, sunif, nmath, sexp, chebyshev, fmax2, fmin2, fsign, imax2, imin2, log1p, qnorm, snorm, rpois
// @load_order: 83

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka and the R Core Team.
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
 *    double rgeom(double p);
 *
 *  DESCRIPTION
 *
 *    Random variates from the geometric distribution.
 *
 *  NOTES
 *
 *    We generate lambda as exponential with scale parameter
 *    p / (1 - p).  Return a Poisson deviate with mean lambda.
 *    See Example 1.5 in Devroye (1986), Chapter 10, pages 488f.
 *
 *  REFERENCE
 *
 *    Devroye, L. (1986).
 *    Non-Uniform Random Variate Generation.
 *    New York: Springer-Verlag.
 *    Pages 488f.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"

double rgeom(double p)
{
    if (!R_FINITE(p) || p <= 0 || p > 1) ML_WARN_return_NAN;

    return rpois(exp_rand() * ((1 - p) / p));
}
