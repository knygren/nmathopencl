// Rconfig.cl - Minimal OpenCL shim for selected <Rconfig.h> macros
// @provides: IEEE_754
// @depends:
// @includes: R
// Intentionally minimal: only macros currently needed by OpenCL nmath ports.

#ifndef OPENCL_R_RCONFIG_CL
#define OPENCL_R_RCONFIG_CL

#ifndef IEEE_754
#define IEEE_754 1
#endif

#endif // OPENCL_R_RCONFIG_CL
