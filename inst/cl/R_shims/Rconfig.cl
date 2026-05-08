// @source_type: h
// @source_origin: Rconfig.h
// @provides: R_CONFIG_H, SIZEOF_SIZE_T, R_INLINE, IEEE_754

#ifndef R_CONFIG_H
#define R_CONFIG_H

/*
 * Minimal shim config for OpenCL portability scaffolding.
 * Keep this intentionally tiny: just enough for dependent typedef logic.
 */
#ifndef SIZEOF_SIZE_T
#define SIZEOF_SIZE_T 8
#endif

#ifndef R_INLINE
#define R_INLINE inline
#endif

#ifndef IEEE_754
#define IEEE_754 1
#endif

#endif /* R_CONFIG_H */
