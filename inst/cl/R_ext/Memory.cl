// @source_type: h
// @source_origin: Memory.h
// @includes: R_ext.h, cstddef, stddef.h
// @depends: R_ext
// @provides: R_EXT_MEMORY_H_, R_SIZE_T, vmaxget , vmaxset , R_gc, R_gc_running, R_alloc, S_alloc, S_realloc, R_malloc_gc, R_calloc_gc, R_realloc_gc
// @used: vmaxget, vmaxset, R_alloc
// @used_includes: stddef.h
// @to_shim: vmaxget, vmaxset, R_alloc
// @to_shim_reason: vmaxget, vmaxset, R_alloc
// @to_shim_kind: vmaxget=reason, vmaxset=reason, R_alloc=reason
// @all_depends_count: 1
// @all_depends: R_ext
// @load_order: 10

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2024  The R Core Team
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
 *
 *
 * Memory Allocation (garbage collected) --- INCLUDING S compatibility ---
 */

/* Included by R.h: Part of the API. */

#ifndef R_EXT_MEMORY_H_
#define R_EXT_MEMORY_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
#if defined(__cplusplus) && !defined(DO_NOT_USE_CXX_HEADERS)
// openclport-disabled-include: # include <cstddef>
# define R_SIZE_T std::size_t
#else
// openclport-disabled-include: # include <stddef.h> /* for size_t */
# define R_SIZE_T size_t
#endif

#ifdef  __cplusplus
extern "C" {
#endif

void*	vmaxget(void); // not remapped
void	vmaxset(const void *); // not re-mapped

void	R_gc(void);
#ifdef USE_BASE_R_SUPPORT
int	R_gc_running(void);
#endif

char*	R_alloc(R_SIZE_T, int);
long double *R_allocLD(R_SIZE_T nelem);
char*	S_alloc(long, int);
char*	S_realloc(char *, long, long, int);

void *  R_malloc_gc(size_t);
void *  R_calloc_gc(size_t, size_t);
void *  R_realloc_gc(void *, size_t);

#ifdef  __cplusplus
}
#endif

#endif /* R_EXT_MEMORY_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
