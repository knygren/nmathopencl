// @source_type: h
// @source_origin: MathThreads.h
// @includes: R_ext.h, libextern.h
// @depends: R_ext, libextern
// @provides: R_EXT_MATHTHREADS_H_
// @used_includes: libextern.h, R_ext/libextern.h
// @all_depends_count: 2
// @all_depends: R_ext, libextern
// @load_order: 9

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2000-2026 The R Core Team.
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

/*
  Experimental: included by src/library/stats/src/distance.c

  This is not used currently on Windows.
*/

#ifndef R_EXT_MATHTHREADS_H_
#define R_EXT_MATHTHREADS_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
// openclport-disabled-include: #include <R_ext/libextern.h>

#ifdef  __cplusplus
extern "C" {
#endif

#ifdef USE_MATH_THREADS
LibExtern int R_num_math_threads;
LibExtern int R_max_num_math_threads;
#endif

#ifdef  __cplusplus
}
#endif

#endif /* R_EXT_MATHTHREADS_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
