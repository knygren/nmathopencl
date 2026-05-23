// @source_type: c
// @source_origin: r_check_user_interrupt.c
// @includes: nmath.h
// @depends: nmath
// @provides: R_CheckUserInterrupt
// @all_depends_count: 2
// @all_depends: Rmath, nmath
// @load_order: 14

/*
 * Portability shim for OpenCL conversion workflows.
 *
 * In R's runtime, R_CheckUserInterrupt() is provided by src/main/errors.c and
 * can abort long-running CPU loops when the user interrupts execution.
 *
 * For kernel-oriented porting here, we keep call sites intact but provide a
 * local no-op definition so dependency analysis and source conversion can
 * resolve this symbol without requiring the full R runtime.
 */
// openclport: include directives disabled for OpenCL C compilation.
// openclport: preload equivalent ported headers/shims in program assembly.
// openclport-disabled-include: #include "nmath.h"

attribute_hidden void R_CheckUserInterrupt(void)
{
    /* no-op in kernel-oriented standalone builds */
}
