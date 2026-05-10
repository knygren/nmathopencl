// @source_type: h
// @source_origin: Random.h
// @includes: R_ext.h, Boolean.h
// @depends:
// @provides: R_RANDOM_H, Int32, WICHMANN_HILL, MARSAGLIA_MULTICARRY, SUPER_DUPER, MERSENNE_TWISTER, KNUTH_TAOCP, USER_UNIF, KNUTH_TAOCP2, LECUYER_CMRG, BUGGY_KINDERMAN_RAMAGE, AHRENS_DIETER, BOX_MULLER, USER_NORM, INVERSION, KINDERMAN_RAMAGE, ROUNDING, REJECTION, R_sample_kind, GetRNGstate, PutRNGstate, unif_rand, R_unif_index, norm_rand, exp_rand, user_unif_rand, user_unif_init, user_unif_nseed, user_unif_seedloc, user_norm_rand
// @used: BUGGY_KINDERMAN_RAMAGE, AHRENS_DIETER, BOX_MULLER, USER_NORM, INVERSION, KINDERMAN_RAMAGE, unif_rand, R_unif_index, norm_rand, exp_rand
// @used_includes: Boolean.h, R_ext/Boolean.h
// @to_shim: BUGGY_KINDERMAN_RAMAGE, AHRENS_DIETER, BOX_MULLER, USER_NORM, INVERSION, KINDERMAN_RAMAGE, unif_rand, R_unif_index, norm_rand, exp_rand
// @to_shim_reason: BUGGY_KINDERMAN_RAMAGE, AHRENS_DIETER, BOX_MULLER, USER_NORM, INVERSION, KINDERMAN_RAMAGE, unif_rand, R_unif_index, norm_rand, exp_rand
// @to_shim_kind: BUGGY_KINDERMAN_RAMAGE=reason, AHRENS_DIETER=reason, BOX_MULLER=reason, USER_NORM=reason, INVERSION=reason, KINDERMAN_RAMAGE=reason, unif_rand=reason, R_unif_index=reason, norm_rand=reason, exp_rand=reason
// @all_depends_count: 0
// @load_order: 13

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2022    The R Core Team
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

#ifndef R_RANDOM_H
#define R_RANDOM_H

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
// openclport-disabled-include: #include <R_ext/Boolean.h>

#ifdef  __cplusplus
extern "C" {
#endif

typedef enum {
    WICHMANN_HILL,
    MARSAGLIA_MULTICARRY,
    SUPER_DUPER,
    MERSENNE_TWISTER,
    KNUTH_TAOCP,
    USER_UNIF,
    KNUTH_TAOCP2,
    LECUYER_CMRG
} RNGtype;

/* Different kinds of "N(0,1)" generators :*/
typedef enum {
    BUGGY_KINDERMAN_RAMAGE,
    AHRENS_DIETER,
    BOX_MULLER,
    USER_NORM,
    INVERSION,
    KINDERMAN_RAMAGE
} N01type;

/* Different ways to generate discrete uniform samples */
typedef enum {
    ROUNDING,
    REJECTION
} Sampletype;
Sampletype R_sample_kind(void);

void GetRNGstate(void);
void PutRNGstate(void);

double unif_rand(void);
double R_unif_index(double);
/* These are also defined in Rmath.h */
double norm_rand(void);
double exp_rand(void);

typedef unsigned int Int32;
double * user_unif_rand(void);
void user_unif_init(Int32);
int * user_unif_nseed(void);
int * user_unif_seedloc(void);

double * user_norm_rand(void);

#ifdef  __cplusplus
}
#endif

#endif /* R_RANDOM_H */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
