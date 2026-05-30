#include "glmbayes_getRegisteredNamespace.h"

#ifdef GLMBAYES_NEED_GETREGISTEREDNAMESPACE_SHIM
#include <Rinternals.h>
#ifdef R_getRegisteredNamespace
#undef R_getRegisteredNamespace
#endif

extern "C" SEXP glmbayes_getRegisteredNamespace(const char *name) {
    SEXP sym = Rf_install(name);

#if R_VERSION < R_Version(4,5,0)
    SEXP val = Rf_findVarInFrame(R_NamespaceRegistry, sym);
    if (val == R_UnboundValue) {
        return R_NilValue;
    }
    return val;
#else
    return R_getVarEx(sym, R_NamespaceRegistry, FALSE, R_NilValue);
#endif
}
#endif
