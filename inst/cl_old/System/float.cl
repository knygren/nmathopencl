// float.cl - Minimal OpenCL shim for selected <float.h> constants
// @provides: FLT_RADIX, FLT_MANT_DIG, FLT_MIN_EXP, FLT_MAX_EXP, FLT_EPSILON, FLT_MIN, FLT_MAX, DBL_MANT_DIG, DBL_MIN_EXP, DBL_MAX_EXP, DBL_DIG, DBL_MAX_10_EXP, DBL_EPSILON, DBL_MIN, DBL_MAX
// @depends:
// @includes: System
// Values target IEEE-754 float/double and are guarded for portability.

#ifndef OPENCL_SYSTEM_FLOAT_CL
#define OPENCL_SYSTEM_FLOAT_CL

#ifndef FLT_RADIX
#define FLT_RADIX 2
#endif

#ifndef FLT_MANT_DIG
#define FLT_MANT_DIG 24
#endif

#ifndef FLT_MIN_EXP
#define FLT_MIN_EXP (-125)
#endif

#ifndef FLT_MAX_EXP
#define FLT_MAX_EXP 128
#endif

#ifndef FLT_EPSILON
#define FLT_EPSILON 1.1920928955078125e-07f
#endif

#ifndef FLT_MIN
#define FLT_MIN 1.1754943508222875e-38f
#endif

#ifndef FLT_MAX
#define FLT_MAX 3.4028234663852886e+38f
#endif

#ifndef DBL_MANT_DIG
#define DBL_MANT_DIG 53
#endif

#ifndef DBL_MIN_EXP
#define DBL_MIN_EXP (-1021)
#endif

#ifndef DBL_MAX_EXP
#define DBL_MAX_EXP 1024
#endif

#ifndef DBL_DIG
#define DBL_DIG 15
#endif

#ifndef DBL_MAX_10_EXP
#define DBL_MAX_10_EXP 308
#endif

#ifndef DBL_EPSILON
#define DBL_EPSILON 2.2204460492503131e-16
#endif

#ifndef DBL_MIN
#define DBL_MIN 2.2250738585072014e-308
#endif

#ifndef DBL_MAX
#define DBL_MAX 1.7976931348623157e+308
#endif

#endif // OPENCL_SYSTEM_FLOAT_CL
