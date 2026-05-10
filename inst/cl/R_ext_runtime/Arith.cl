// @source_type: h
// @source_origin: Arith.h
// @includes: R_ext.h, libextern.h, math.h
// @depends:
// @provides: R_ARITH_H_, NA_LOGICAL, NA_INTEGER, NA_REAL, ISNA, ISNAN, R_FINITE, R_IsNA		, R_IsNaN		, R_finite		, R_isnancpp 
// @used: NA_INTEGER, NA_REAL, ISNAN, R_FINITE, R_finite, R_isnancpp
// @used_includes: libextern.h, math.h, R_ext/libextern.h
// @to_shim: NA_INTEGER, NA_REAL, ISNAN, R_FINITE, R_finite, R_isnancpp
// @to_shim_deterministic: NA_INTEGER, NA_REAL, ISNAN, R_FINITE
// @to_shim_reason: R_finite, R_isnancpp
// @to_shim_kind: NA_INTEGER=define_object_identifier, NA_REAL=define_object_identifier, ISNAN=define_function_macro, R_FINITE=define_function_macro, R_finite=reason, R_isnancpp=reason
// @all_depends_count: 0
// @load_order: 16

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1995, 1996  Robert Gentleman and Ross Ihaka
 *  Copyright (C) 1998--2016  The R Core Team.
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

#ifndef R_ARITH_H_
#define R_ARITH_H_

/* 
   This used to define _BSD_SOURCE to make declarations of isfinite
   and isnan visible in glibc.  But that was deprecated in glibc 2.20,
   and --std=c99 suffices nowadays.
*/

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
// openclport-disabled-include: #include <R_ext/libextern.h>
#ifdef  __cplusplus
extern "C" {
#else
/* needed for isnan and isfinite, neither of which are used under C++ */
// openclport-disabled-include: # include <math.h>
#endif

/* implementation of these : ../../main/arithmetic.c */
LibExtern double R_NaN;		/* IEEE NaN */
LibExtern double R_PosInf;	/* IEEE Inf */
LibExtern double R_NegInf;	/* IEEE -Inf */
LibExtern double R_NaReal;	/* NA_REAL: IEEE */
LibExtern int	 R_NaInt;	/* NA_INTEGER:= INT_MIN currently */
#ifdef __MAIN__
#undef extern
#undef LibExtern
#endif

#define NA_LOGICAL	R_NaInt
#define NA_INTEGER	R_NaInt
/* #define NA_FACTOR	R_NaInt  unused */
#define NA_REAL		R_NaReal
/* NA_STRING is a SEXP, so defined in Rinternals.h */

int R_IsNA(double);		/* True for R's NA only */
int R_IsNaN(double);		/* True for special NaN, *not* for NA */
int R_finite(double);		/* True if none of NA, NaN, +/-Inf */
#define ISNA(x)	       R_IsNA(x)

/* ISNAN(): True for *both* NA and NaN.
   NOTE: some systems do not return 1 for TRUE.
   Also note that C++ math headers specifically undefine
   isnan if it is a macro (it is on macOS and in C99),
   hence the workaround.  This code also appears in Rmath.h
*/
#ifdef __cplusplus
  int R_isnancpp(double); /* in arithmetic.c */
#  define ISNAN(x)     R_isnancpp(x)
#else
#  define ISNAN(x)     (isnan(x)!=0)
#endif

/* Configure-time feature gate:
   host R builds may define this via config headers; OpenCL/device builds
   should provide it from prelude/shim configuration. */
#ifdef HAVE_WORKING_ISFINITE
/* isfinite is defined in <math.h> according to C99 */
# define R_FINITE(x)    isfinite(x)
#else
# define R_FINITE(x)    R_finite(x)
#endif

#ifdef  __cplusplus
}
#endif

#endif /* R_ARITH_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
