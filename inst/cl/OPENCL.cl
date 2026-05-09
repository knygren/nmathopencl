/*
 * OPENCL.cl - global OpenCL configuration header
 *
 * This file is intended to be stitched at the top of an assembled OpenCL
 * program. Packages can copy and customize this header for their own kernels.
 */

#ifndef OPENCLPORT_OPENCL_CL
#define OPENCLPORT_OPENCL_CL

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#if defined(__OPENCL_C_VERSION__) && (__OPENCL_C_VERSION__ >= 120)
  #define HAVE_EXPM1 1
  #define HAVE_LOG1P 1
#else
  #define HAVE_EXPM1 0
  #define HAVE_LOG1P 0
#endif

#ifndef ML_NAN
  #define ML_NAN nan("")
  #define ML_POSINF INFINITY
  #define ML_NEGINF -INFINITY
#endif

#ifndef INLINE
  #define INLINE static inline
#endif

#ifndef R_UNUSED
  #define R_UNUSED(x) (void)(x)
#endif

#endif
