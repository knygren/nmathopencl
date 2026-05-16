// @source_type: c
// @source_origin: pweibull.c
// @includes: nmath.h, dpq.h
// @depends: expm1, nmath, dpq
// @provides: pweibull
// @all_depends_count: 6
// @all_depends: dpq, Rmath, nmath, chebyshev, log1p, expm1
// @load_order: 66

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000-2015 The R Core Team
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
 *    The distribution function of the Weibull distribution.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double pweibull(double x, double shape, double scale, int lower_tail, int log_p)
{
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(shape) || ISNAN(scale))
	return x + shape + scale;
#endif
    if(shape <= 0 || scale <= 0) ML_WARN_return_NAN;

    if (x <= 0)
	return R_DT_0;
    x = -pow(x / scale, shape);
    return lower_tail
	? (log_p ? R_Log1_Exp(x) : -expm1(x))
	: R_D_exp(x);
}
