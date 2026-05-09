// @source_type: h
// @source_origin: Print.h
// @includes: R_ext.h, cstdarg, stdarg.h
// @depends: R_ext
// @provides: R_EXT_PRINT_H_, R_USE_C99_IN_CXX, R_VA_LIST, R_PRINTF_FORMAT, Rprintf, REprintf, Rvprintf, REvprintf
// @used_includes: stdarg.h
// @all_depends_count: 1
// @all_depends: R_ext
// @load_order: 12

/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2024    The R Core Team
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

#ifndef R_EXT_PRINT_H_
#define R_EXT_PRINT_H_

// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include <R_ext.h>
#ifdef  __cplusplus
/* If the vprintf interface is defined at all in C++ it may only be
   defined in namespace std.  It is part of the C++11 standard. */
# if __cplusplus >= 201103L && !defined(R_USE_C99_IN_CXX)
#  define R_USE_C99_IN_CXX
# endif
# ifdef R_USE_C99_IN_CXX
// openclport-disabled-include: #  include <cstdarg>
#  define R_VA_LIST std::va_list
# endif
extern "C" {
#else
// openclport-disabled-include: # include <stdarg.h>
# define R_VA_LIST va_list
#endif

#ifdef __GNUC__
# ifdef _WIN32
#  if defined(_UCRT) || ((__MSVCRT_VERSION__ >= 0x1400) || \
                        (__MSVCRT_VERSION__ >= 0xE00 && __MSVCRT_VERSION__ < 0x1000))
#   if defined(__clang__)
#    define R_PRINTF_FORMAT(M,N) __attribute__ ((format (printf, M, N)))    
#   else
#    define R_PRINTF_FORMAT(M,N) __attribute__ ((format (gnu_printf, M, N)))    
#   endif
#  else
#   define R_PRINTF_FORMAT(M,N)
#  endif
# else
#  define R_PRINTF_FORMAT(M,N) __attribute__ ((format (printf, M, N)))
# endif
#else
# define R_PRINTF_FORMAT(M,N)
#endif

#ifdef __OPENCL_VERSION__
/* OpenCL C disallows variadic function declarations/prototypes. */
# undef Rprintf
# undef REprintf
# define Rprintf(...) ((void)0)
# define REprintf(...) ((void)0)

# if !defined(__cplusplus) || defined R_USE_C99_IN_CXX
#  undef Rvprintf
#  undef REvprintf
#  define Rvprintf(...) ((void)0)
#  define REvprintf(...) ((void)0)
# endif
#else
void Rprintf(const char *, ...) R_PRINTF_FORMAT(1, 2);
void REprintf(const char *, ...) R_PRINTF_FORMAT(1, 2);

# if !defined(__cplusplus) || defined R_USE_C99_IN_CXX

void Rvprintf(const char *, R_VA_LIST) R_PRINTF_FORMAT(1, 0);
void REvprintf(const char *, R_VA_LIST) R_PRINTF_FORMAT(1, 0);

# endif
#endif

#ifdef  __cplusplus
}
#endif

#endif /* R_EXT_PRINT_H_ */

// ---- BEGIN AUTO DETERMINISTIC SHIM ----
// (none)
// ---- END AUTO DETERMINISTIC SHIM ----

// ---- BEGIN MANUAL REASONED SHIM ----
// (none)
// ---- END MANUAL REASONED SHIM ----
