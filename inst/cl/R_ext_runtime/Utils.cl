// @source_type: h
// @source_origin: Utils.h
// @includes: R_ext.h, Boolean.h, Complex.h, cstddef, stddef.h
// @depends:
// @provides: R_EXT_UTILS_H_, R_SIZE_T, revsort, iPsort, rPsort, cPsort, IndexWidth, StringFalse, StringTrue, isBlankString, R_isort, R_rsort, R_csort, rsort_with_index , R_qsort, R_qsort_I, R_qsort_int, R_qsort_int_I, F77_NAME, F77_SUB, StringFalse , StringTrue , isBlankString , R_atof, R_strtod, R_free_tmpnam, R_CheckUserInterrupt, R_CheckStack, R_CheckStack2, R_max_col
// @used: F77_SUB, R_CheckUserInterrupt, R_CheckStack
// @used_includes: Boolean.h, stddef.h, R_ext/Boolean.h
// @to_shim: F77_SUB, R_CheckUserInterrupt, R_CheckStack
// @to_shim_reason: F77_SUB, R_CheckUserInterrupt, R_CheckStack
// @to_shim_kind: F77_SUB=reason, R_CheckUserInterrupt=reason, R_CheckStack=reason
// @all_depends_count: 0
// @load_order: 15

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2026    The R Core Team
 *
 *  This header file is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.

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
 *
 *
 * Generally useful  UTILITIES  *NOT* relying on R internals (from Defn.h)
 */

/* Included by R.h: some are API (documented in R-exts), 
   others are noted below. */

#ifndef R_EXT_UTILS_H_
#define R_EXT_UTILS_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
// openclport-disabled-include: #include <R_ext/Boolean.h>
// openclport-disabled-include: #include <R_ext/Complex.h>

#if defined(__cplusplus) && !defined(DO_NOT_USE_CXX_HEADERS)
// openclport-disabled-include: # include <cstddef>
# define R_SIZE_T std::size_t
#else
// openclport-disabled-include: # include <stddef.h>
# define R_SIZE_T size_t
#endif

#define revsort       Rf_revsort
#define iPsort        Rf_iPsort
#define rPsort        Rf_rPsort
#define cPsort        Rf_cPsort
#define IndexWidth    Rf_IndexWidth
//#define setIVector    Rf_setIVector
//#define setRVector    Rf_setRVector
#define StringFalse   Rf_StringFalse
#define StringTrue    Rf_StringTrue
#define isBlankString Rf_isBlankString

#ifdef  __cplusplus
extern "C" {
#endif

/* ../../main/sort.c : */
void	R_isort(int*, int);
void	R_rsort(double*, int);
void	R_csort(Rcomplex*, int);
void    rsort_with_index(double *, int *, int); // not remapped.
void	revsort(double*, int*, int);/* reverse; sort i[] alongside */
void	iPsort(int*,    int, int);
void	rPsort(double*, int, int);
void	cPsort(Rcomplex*, int, int);

/* ../../main/qsort.c : */
/* dummy renamed to II to avoid problems with g++ on Solaris */
void R_qsort    (double *v,         R_SIZE_T i, R_SIZE_T j);
void R_qsort_I  (double *v, int *II, int i, int j);
void R_qsort_int  (int *iv,         R_SIZE_T i, R_SIZE_T j);
void R_qsort_int_I(int *iv, int *II, int i, int j);
#ifdef R_RS_H
void F77_NAME(qsort4)(double *v, int *indx, int *ii, int *jj);
void F77_NAME(qsort3)(double *v,            int *ii, int *jj);
#endif

// listed as callable from C in WRE
#ifdef R_RS_H
int F77_SUB(i1mach)(int *i);
double F77_SUB(d1mach)(int *i);
#endif
    
/* ../../main/util.c  and others : */
const char *R_ExpandFileName(const char *);
#ifdef Win32
// not API
const char *R_ExpandFileNameUTF8(const char *);
#endif
/*  attribute_hidden and no longer used.
void	setIVector(int*, int, int);
void	setRVector(double*, int, double);
*/
/* Not API */
Rboolean StringFalse(const char *); // used by iotools
Rboolean StringTrue(const char *); // used by iotools
Rboolean isBlankString(const char *); // used by iotools and openxlsx2

/* These two are guaranteed to use '.' as the decimal point,
   and to accept "NA". Documented since 4.4.0 patched.
 */
double R_atof(const char *str);
double R_strtod(const char *c, char **end);

char *R_tmpnam(const char *prefix, const char *tempdir);
char *R_tmpnam2(const char *prefix, const char *tempdir, const char *fileext);
void R_free_tmpnam(char *name);

void R_CheckUserInterrupt(void);
void R_CheckStack(void);
void R_CheckStack2(R_SIZE_T);


/* ../../appl/interv.c: first and also in Applic.h 
   Both are API
*/
int findInterval(double *xt, int n, double x,
		 Rboolean rightmost_closed,  Rboolean all_inside, int ilo,
		 int *mflag);
int findInterval2(double *xt, int n, double x,
		  Rboolean rightmost_closed,  Rboolean all_inside, Rboolean left_open,
		  int ilo, int *mflag);
/* Removed in 4.5.0, but still API according too WRE */
#ifdef R_RS_H
// Was Rboolean*, but that is not possible in Fortran.
int F77_SUB(interv)(double *xt, int *n, double *x,
		    int *rightmost_closed, int *all_inside,
		    int *ilo, int *mflag);
#endif
 
/* not API, no longer in R
void find_interv_vec(double *xt, int *n,	double *x,   int *nx,
		     int *rightmost_closed, int *all_inside, int *indx);
*/

/* ../../appl/maxcol.c */
void R_max_col(double *matrix, int *nr, int *nc, int *maxes, int *ties_meth);

#ifdef  __cplusplus
}
#endif

#endif /* R_EXT_UTILS_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
