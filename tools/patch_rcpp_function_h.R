# Optional post-install patch for Rcpp Function.h when the #elif branch still uses
# R_getVarEx(..., R_NamespaceRegistry, ...) but R no longer exposes R_NamespaceRegistry.
# Replaces that line with R_getRegisteredNamespace() — only useful for specific R-devel snapshots.
#
# OFF by default: do not run during normal configure (r-universe, local R 4.5/4.6). Mutating
# installed Rcpp confuses builds; on R >= 4.6 the active #else branch already uses
# R_getRegisteredNamespace — a broken toolchain needs a newer Rcpp/R, not this patch.
#
# Enable only in controlled CI: GLMBAYES_PATCH_RCPP_FUNCTION_H=1 (see .github/workflows/rhub.yaml).
#
# Usage: GLMBAYES_PATCH_RCPP_FUNCTION_H=1 Rscript tools/patch_rcpp_function_h.R
# Lib: GLMBAYES_RCPP_LIB or R_LIBS_USER or .libPaths()[1]

if (!nzchar(Sys.getenv("GLMBAYES_PATCH_RCPP_FUNCTION_H", "")) ||
      Sys.getenv("GLMBAYES_PATCH_RCPP_FUNCTION_H") %in% c("0", "false", "FALSE", "no", "NO")) {
  message(
    "patch_rcpp_function_h: GLMBAYES_PATCH_RCPP_FUNCTION_H unset or false — skip ",
    "(opt-in only; avoids mutating Rcpp on r-universe / local installs)"
  )
  quit(status = 0L)
}

lib <- Sys.getenv("GLMBAYES_RCPP_LIB", "")
if (!nzchar(lib)) lib <- Sys.getenv("R_LIBS_USER", "")
if (!nzchar(lib)) lib <- .libPaths()[1L]

fh <- file.path(lib, "Rcpp", "include", "Rcpp", "Function.h")
if (!file.exists(fh)) {
  message("patch_rcpp_function_h: missing ", fh, " — skip")
  quit(status = 0L)
}

lines <- readLines(fh, warn = FALSE)

# 1) Single-line form (CRAN / GitHub): entire call on one line
idx <- which(
  grepl("R_getVarEx", lines, fixed = TRUE) &
    grepl("R_NamespaceRegistry", lines, fixed = TRUE) &
    grepl("R_UnboundValue|R_NilValue", lines, perl = TRUE)
)
if (length(idx)) {
  i <- idx[[1L]]
  indent <- regmatches(lines[i], regexpr("^[[:space:]]*", lines[i], perl = TRUE))
  if (!length(indent) || !nzchar(indent[1L])) {
    indent <- ""
  } else {
    indent <- indent[1L]
  }
  lines[i] <- paste0(indent, "Shield<SEXP> env(R_getRegisteredNamespace(ns.c_str()));")
  writeLines(lines, fh)
  message("patch_rcpp_function_h: patched line ", i, " in ", fh)
  quit(status = 0L)
}

# 2) Fallback: whole-file regex (multiline / odd spacing)
txt <- paste(lines, collapse = "\n")
pat <- paste0(
  "(?s)Shield(?:<SEXP>)?[[:space:]]+env\\(",
  "R_getVarEx\\(",
  "Rf_install\\(ns\\.c_str\\(\\)\\),[[:space:]]*",
  "R_NamespaceRegistry,[[:space:]]*FALSE,[[:space:]]*",
  "R_(?:UnboundValue|NilValue)",
  "\\)\\)[[:space:]]*;"
)
repl <- "Shield<SEXP> env(R_getRegisteredNamespace(ns.c_str()));"

if (!grepl(pat, txt, perl = TRUE)) {
  message("patch_rcpp_function_h: no R_getVarEx/R_NamespaceRegistry pattern matched — skip")
  quit(status = 0L)
}

txt2 <- gsub(pat, repl, txt, perl = TRUE)
if (identical(txt2, txt)) {
  quit(status = 0L)
}
writeLines(strsplit(txt2, "\n", fixed = TRUE)[[1L]], fh)
message("patch_rcpp_function_h: patched (regex) ", fh)
