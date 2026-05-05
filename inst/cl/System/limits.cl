// limits.cl - Minimal OpenCL shim for selected <limits.h> constants
// @provides: CHAR_BIT, INT_MAX
// @depends:
// @includes: System
// Intentionally minimal: only constants currently needed by i1mach.cl.

#ifndef OPENCL_SYSTEM_LIMITS_CL
#define OPENCL_SYSTEM_LIMITS_CL

#ifndef CHAR_BIT
#define CHAR_BIT 8
#endif

#ifndef INT_MAX
#define INT_MAX 2147483647
#endif

#endif // OPENCL_SYSTEM_LIMITS_CL
