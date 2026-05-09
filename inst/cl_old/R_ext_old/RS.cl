// RS.cl - Minimal OpenCL shim for R_ext/RS.h
// @provides: F77_CALL, F77_NAME, F77_SUB
// @depends:
// @includes: R_ext
// Only provides Fortran-name mapping macros needed by nmath OpenCL ports.
// Intentionally excludes host-side memory/runtime APIs from RS.h.

#ifndef R_RS_CL
#define R_RS_CL

// In OpenCL device code we only need token mapping for legacy F77 names.
// Use underscore mapping to match typical R builds with HAVE_F77_UNDERSCORE.
#define F77_CALL(x) x ## _
#define F77_NAME(x) F77_CALL(x)
#define F77_SUB(x)  F77_CALL(x)

#endif // R_RS_CL
