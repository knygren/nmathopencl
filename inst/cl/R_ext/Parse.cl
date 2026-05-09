// @source_type: h
// @source_origin: Parse.h
// @includes: R_ext.h
// @depends: R_ext
// @provides: R_EXT_PARSE_H_, PARSE_NULL, PARSE_OK, PARSE_INCOMPLETE, PARSE_ERROR, PARSE_EOF, R_ParseVector
// @all_depends_count: 1
// @all_depends: R_ext
// @load_order: 11

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2006 R Core Team
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
 */

/* NOTE:
   This file exports a part of the current internal parse interface.
   It is subject to change at any minor (x.y.0) version of R.
   So not API.
 */

#ifndef R_EXT_PARSE_H_
#define R_EXT_PARSE_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
#ifdef __cplusplus
extern "C" {
#endif

/* PARSE_NULL will not be returned by R_ParseVector */
typedef enum {
    PARSE_NULL,
    PARSE_OK,
    PARSE_INCOMPLETE,
    PARSE_ERROR,
    PARSE_EOF
} ParseStatus;

SEXP R_ParseVector(SEXP, int, ParseStatus *, SEXP);

#ifdef __cplusplus
}
#endif

#endif

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
