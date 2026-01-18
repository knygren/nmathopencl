# ----------------------------------------------------------------------
# Internal RcppParallel usage helper
#
# This file defines a small internal R function whose sole purpose is to
# establish an R‑level reference to RcppParallel::RcppParallelLibs().
#
# Why this is needed:
#   • The package uses RcppParallel exclusively from C++ code.
#   • R CMD check requires that any package listed in Imports be used
#     from R code, not only from compiled code.
#   • Without an R‑level call, R CMD check emits the NOTE:
#         "Namespace in Imports field not imported from: 'RcppParallel'"
#
# What this function does:
#   • It calls RcppParallelLibs() once, invisibly.
#   • It is never called by users or by the package at runtime.
#   • It exists solely to satisfy R CMD check and to justify the
#     importFrom(RcppParallel, RcppParallelLibs) entry in NAMESPACE.
#
# What this function does *not* do:
#   • It does not affect linking (handled by configure/Makevars).
#   • It does not run at load time (avoids startup messages).
#   • It does not alter package behavior in any way.
#
# This pattern is used by several CRAN packages that rely on RcppParallel
# only in C++ and need a minimal R‑level reference to satisfy R CMD check.
# ----------------------------------------------------------------------

#' @keywords internal
#' @noRd
use_RcppParallel <- function() {
  RcppParallel::RcppParallelLibs()
  invisible(NULL)
}