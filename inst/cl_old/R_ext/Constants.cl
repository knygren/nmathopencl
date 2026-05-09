// @source_type: h
// @source_origin: Constants.h
// @includes: R_ext.h, cfloat, float.h
// @depends: R_ext
// @provides: R_EXT_CONSTANTS_H_, M_PI
// @all_depends_count: 1
// @all_depends: R_ext
// @load_order: 7

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1995, 1996  Robert Gentleman and Ross Ihaka
 *  Copyright (C) 1998-2024   The R Core Team.
 *
 *  This header file is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.
 *
 *  This file is part of R. R is distributed under the terms of the
 *  GNU General Public License, either Version 2, June 1991 or Version 3,
 *  June 2007. See doc/COPYRIGHTS for details of the copyright status of R.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 */

/* Included by R.h: Part of the API. */

#ifndef R_EXT_CONSTANTS_H_
#define R_EXT_CONSTANTS_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
/* usually in math.h, but not with strict C99/C++11 compliance.
   Also in Rmath.h
 */
#ifndef M_PI
#define M_PI 3.141592653589793238462643383279502884197169399375
#endif

/*
  S-compatibility defines.
 */
#ifdef __cplusplus
// openclport-disabled-include: # include <cfloat>   /* Defines the RHSs, C++11 and later */
#else
// openclport-disabled-include: # include <float.h>  /* Defines the RHSs, C99 and later */
#endif

/* #ifndef STRICT_R_HEADERS
# define PI             M_PI
#endif
*/

/* The DOUBLE_* defines were deprecated in R 4.2.0 and removed in 4.3.0.
#define DOUBLE_DIGITS  DBL_MANT_DIG
#define DOUBLE_EPS     DBL_EPSILON
#define DOUBLE_XMAX    DBL_MAX
#define DOUBLE_XMIN    DBL_MIN
*/

#endif /* R_EXT_CONSTANTS_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
