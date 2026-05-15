// @source_type: c
// @source_origin: dweibull.c
// @includes: nmath.h, dpq.h
// @depends: nmath, dpq
// @provides: dweibull
// @all_depends_count: 3
// @all_depends: dpq, Rmath, nmath
// @load_order: 33

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998 Ross Ihaka
 *  Copyright (C) 2000-6 The R Core Team
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
 *    The density function of the Weibull distribution.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double dweibull(double x, double shape, double scale, int give_log)
{
    double tmp1, tmp2;
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(shape) || ISNAN(scale))
	return x + shape + scale;
#endif
    if (shape <= 0 || scale <= 0) ML_WARN_return_NAN;

    if (x < 0) return R_D__0;
    if (!R_FINITE(x)) return R_D__0;
    /* need to handle x == 0 separately */
    if(x == 0 && shape < 1) return ML_POSINF;
    tmp1 = pow(x / scale, shape - 1);
    tmp2 = tmp1 * (x / scale);
    /* These are incorrect if tmp1 == 0 */
    return  give_log ?
	-tmp2 + log(shape * tmp1 / scale) :
	shape * tmp1 * exp(-tmp2) / scale;
}
