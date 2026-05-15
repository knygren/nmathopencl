// @source_type: c
// @source_origin: dunif.c
// @includes: nmath.h, dpq.h
// @depends: nmath, dpq
// @provides: dunif
// @all_depends_count: 3
// @all_depends: dpq, Rmath, nmath
// @load_order: 32

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
 *  DESCRIPTION
 *
 *    The density of the uniform distribution.
 */

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"
// openclport-disabled-include: #include "dpq.h"

double dunif(double x, double a, double b, int give_log)
{
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(a) || ISNAN(b))
	return x + a + b;
#endif
    if (b <= a) ML_WARN_return_NAN;

    if (a <= x && x <= b)
	return give_log ? -log(b - a) : 1. / (b - a);
    return R_D__0;
}
