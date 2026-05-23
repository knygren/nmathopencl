// @source_type: c
// @source_origin: mlutils.c
// @includes: config.h, nmath.h
// @depends: nmath
// @all_depends_count: 2
// @all_depends: Rmath, nmath
// @load_order: 46

/*
 *  Mathlib : A C Library of Special Functions
 *  Copyright (C) 1998-2025 The R Core Team
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

#ifdef HAVE_CONFIG_H
// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: # include <config.h>
# undef fprintf
#endif
// openclport-disabled-include: #include "nmath.h"

