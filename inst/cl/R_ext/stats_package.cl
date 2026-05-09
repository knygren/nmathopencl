// @source_type: h
// @source_origin: stats_package.h
// @includes: R_ext.h, Rconfig.h, Visibility.h
// @depends: R_ext, Visibility
// @provides: R_STATS_PACKAGE_H, NREG, OPT, F, F0, FDIF, G, HC, AI, AM, ALGSAV, COVMAT, COVPRT, COVREQ, DRADPR, DTYPE, IERR, INITH, INITS, IPIVOT, IVNEED, LASTIV, LASTV, LMAT, MXFCAL, MXITER, NEXTV, NFCALL, NFCOV, NFGCAL, NGCOV, NITER, NVDFLT, NVSAVE, OUTLEV, PARPRT, PARSAV, PERM, PRUNIT, QRTYP, RDREQ, RMAT, SOLPRT, STATPR, TOOBIG, VNEED, VSAVE, X0PRT
// @used: F, F0, G
// @used_includes: Rconfig.h, Visibility.h, R_ext/Visibility.h
// @to_shim: F, F0, G
// @to_shim_reason: F, F0, G
// @to_shim_kind: F=reason, F0=reason, G=reason
// @all_depends_count: 2
// @all_depends: R_ext, Visibility
// @load_order: 14

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2007--2025  The R Core Team.
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

/* Not part of the API, not callable from C++ */

#ifndef R_STATS_PACKAGE_H
#define R_STATS_PACKAGE_H
// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
// openclport-disabled-include: #include <Rconfig.h>
// openclport-disabled-include: #include <R_ext/Visibility.h>

/*
#ifdef HAVE_VISIBILITY_ATTRIBUTE
# define attribute_hidden __attribute__ ((visibility ("hidden")))
#else
# define attribute_hidden
#endif
*/

enum AlgType {NREG = 1, OPT = 2};
				/* 0-based indices into v */
enum  VPos {F = 9, F0 = 12, FDIF = 10, G = 27, HC = 70};
				/* 0-based indices into iv */
enum IVPos {AI = 90, AM = 94, ALGSAV = 50, COVMAT = 25,
	    COVPRT = 13, COVREQ = 14, DRADPR = 100,
	    DTYPE = 15, IERR = 74, INITH = 24, INITS = 24,
	    IPIVOT = 75, IVNEED =  2, LASTIV = 42, LASTV = 44,
	    LMAT =  41, MXFCAL = 16, MXITER = 17, NEXTV  = 46,
	    NFCALL =  5, NFCOV = 51, NFGCAL = 6, NGCOV = 52,
	    NITER = 30, NVDFLT = 49, NVSAVE = 8, OUTLEV = 18,
	    PARPRT = 19, PARSAV = 48, PERM = 57, PRUNIT = 20,
	    QRTYP = 79, RDREQ = 56, RMAT = 77, SOLPRT = 21,
	    STATPR = 22, TOOBIG = 1, VNEED = 3, VSAVE = 59,
	    X0PRT = 23};

attribute_hidden void
S_Rf_divset(int alg, int iv[], int liv, int lv, double v[]);

attribute_hidden void
S_nlsb_iterate(double b[], double d[], double dr[], int iv[],
	       int liv, int lv, int n, int nd, int p,
	       double r[], double rd[], double v[], double x[]);

attribute_hidden void
S_nlminb_iterate(double b[], double d[], double fx, double g[],
		 double h[], int iv[], int liv, int lv, int n,
		 double v[], double x[]);

attribute_hidden void
S_rcont2(int nrow, int ncol, const int nrowt[], const int ncolt[],
         int ntotal, const double fact[],
	 int jwork[], int matrix[]);

static R_INLINE int S_v_length(int alg, int n)
{
    return (alg - 1) ? (105 + (n * (2 * n + 20))) :
	(130 + (n * (n + 27))/2);
}

static R_INLINE int S_iv_length(int alg, int n)
{
    return (alg - 1) ? (82 + 4 * n) : (78 + 3 * n);
}

#endif /* R_STATS_PACKAGE_H */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
