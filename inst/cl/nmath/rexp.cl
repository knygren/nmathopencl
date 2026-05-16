// @source_type: c
// @source_origin: rexp.c
// @includes: nmath.h
// @depends: sexp, nmath
// @provides: rexp
// @all_depends_count: 4
// @all_depends: Rmath, sunif, nmath, sexp
// @load_order: 52

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000--2008 The R Core Team
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
 *    double rexp(double scale)
 *
 *  DESCRIPTION
 *
 *    Random variates from the exponential distribution.
 *
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"

double rexp(double scale)
{
    if (!R_FINITE(scale) || scale <= 0.0) {
	if(scale == 0.) return 0.;
	/* else */
	ML_WARN_return_NAN;
    }
    return scale * exp_rand(); // --> in ./sexp.c
}
