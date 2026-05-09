// @source_type: h
// @source_origin: stdint_shim_opencl.h
// @provides: OPENCL_STDINT_SHIM_H, int64_t, uint64_t, int_least64_t, uint_least64_t
// @depends:
// @includes: System

#ifndef OPENCL_STDINT_SHIM_H
#define OPENCL_STDINT_SHIM_H

/* Minimal stdint shim for OpenCL nmath staging.
   Keep this intentionally small: add more typedefs only as needed. */

#if defined(__OPENCL_VERSION__) || defined(__OPENCL_C_VERSION__)
typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int64_t int_least64_t;
typedef uint64_t uint_least64_t;
#else
/* Host fallback if compiled outside OpenCL toolchain */
typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int64_t int_least64_t;
typedef uint64_t uint_least64_t;
#endif

#endif /* OPENCL_STDINT_SHIM_H */
