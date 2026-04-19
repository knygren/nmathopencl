# Post-install patch for Rcpp headers on R-devel/R 4.5.x when R no longer declares
# R_NamespaceRegistry but Rcpp still uses it in the R 4.5.* #elif branch.
# Replaces the R_getVarEx(..., R_NamespaceRegistry, ...) line with R_getRegisteredNamespace.
#
# Usage: Rscript tools/patch_rcpp_function_h.R
# Lib: GLMBAYES_RCPP_LIB or R_LIBS_USER or .libPaths()[1]

lib <- Sys.getenv("GLMBAYES_RCPP_LIB", "")
if (!nzchar(lib)) lib <- Sys.getenv("R_LIBS_USER", "")
if (!nzchar(lib)) lib <- .libPaths()[1L]

fh <- file.path(lib, "Rcpp", "include", "Rcpp", "Function.h")
if (!file.exists(fh)) {
  message("patch_rcpp_function_h: missing ", fh, " — skip")
  quit(status = 0L)
}

txt <- paste(readLines(fh, warn = FALSE), collapse = "\n")
orig <- txt

# Whitespace-tolerant (indent may vary). R_UnboundValue = CRAN; R_NilValue = GitHub.
pat <- paste0(
  "Shield(?:<SEXP>)?[[:space:]]+env\\(",
  "R_getVarEx\\(",
  "Rf_install\\(ns\\.c_str\\(\\)\\),[[:space:]]*",
  "R_NamespaceRegistry,[[:space:]]*FALSE,[[:space:]]*",
  "R_(?:UnboundValue|NilValue)",
  "\\)\\)[[:space:]]*;"
)
repl <- "Shield env(R_getRegisteredNamespace(ns.c_str()));"

if (!grepl(pat, txt, perl = TRUE)) {
  message("patch_rcpp_function_h: no R_getVarEx/R_NamespaceRegistry line matched — skip")
  quit(status = 0L)
}

txt <- gsub(pat, repl, txt, perl = TRUE)
if (identical(txt, orig)) {
  quit(status = 0L)
}

writeLines(strsplit(txt, "\n", fixed = TRUE)[[1L]], fh)
message("patch_rcpp_function_h: patched ", fh)
