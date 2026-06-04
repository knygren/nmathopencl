#!/usr/bin/env Rscript
# Generate inst/include/nmathopencl/nmathopencl_capi.h and
# src/nmathopencl_ccallables.cpp from src/export_wrappers.cpp.
#
# Usage (from package root):
#   Rscript tools/generate_nmathopencl_capi.R

args <- commandArgs(trailingOnly = TRUE)
pkg_root <- if (length(args) >= 1L) args[[1L]] else {
  cand <- Sys.getenv("NMATHOPENCL_ROOT", unset = "")
  if (nzchar(cand)) cand else {
    here <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(here, "DESCRIPTION"))) here
    else normalizePath(file.path(here, ".."), winslash = "/", mustWork = TRUE)
  }
}

export_file <- file.path(pkg_root, "src", "export_wrappers.cpp")
if (!file.exists(export_file)) {
  stop("Cannot find ", export_file, call. = FALSE)
}

src <- readLines(export_file, warn = FALSE)
blocks <- split(src, cumsum(grepl("^// \\[\\[Rcpp::export\\]\\]", src)))

parse_params <- function(lines) {
  start <- grep("^[A-Za-z].*_opencl_cpp_export\\(", lines)[1L]
  if (is.na(start)) return(NULL)
  buf <- character()
  depth <- 0L
  for (i in seq(start, length(lines))) {
    line <- lines[[i]]
    if (i == start) {
      line <- sub("^[^(]*\\(", "(", line)
      if (!startsWith(line, "(")) line <- paste0("(", line)
    }
    buf <- c(buf, line)
    depth <- depth + nchar(gsub("[^(]", "", line)) - nchar(gsub("[^)]", "", line))
    if (depth <= 0L && grepl("\\)", line)) break
  }
  text <- paste(buf, collapse = "\n")
  text <- gsub("[\n\r]", " ", text)
  text <- sub("^\\(", "", text)
  text <- sub("\\)\\s*$", "", text)
  if (!nzchar(text)) return(list())
  parts <- strsplit(text, ",")[[1L]]
  params <- list()
  for (p in parts) {
    p <- trimws(p)
    if (!nzchar(p)) next
    p <- sub("\\s*=\\s*[^,]+$", "", p)
    if (grepl("^const Rcpp::NumericVector&\\s+(\\w+)$", p, perl = TRUE)) {
      params[[length(params) + 1L]] <- list(
        name = sub("^.*&\\s+", "", p),
        SEXP = "SEXP",
        as = "Rcpp::NumericVector"
      )
    } else if (grepl("^const Rcpp::IntegerVector&\\s+(\\w+)$", p, perl = TRUE)) {
      params[[length(params) + 1L]] <- list(
        name = sub("^.*&\\s+", "", p),
        SEXP = "SEXP",
        as = "Rcpp::IntegerVector"
      )
    } else if (grepl("^int\\s+(\\w+)$", p, perl = TRUE)) {
      params[[length(params) + 1L]] <- list(
        name = sub("^int\\s+", "", p),
        SEXP = "SEXP",
        as = "int"
      )
    } else if (grepl("^double\\s+(\\w+)$", p, perl = TRUE)) {
      params[[length(params) + 1L]] <- list(
        name = sub("^double\\s+", "", p),
        SEXP = "SEXP",
        as = "double"
      )
    } else if (grepl("^bool\\s+(\\w+)$", p, perl = TRUE)) {
      params[[length(params) + 1L]] <- list(
        name = sub("^bool\\s+", "", p),
        SEXP = "SEXP",
        as = "bool"
      )
    } else {
      stop("Unparsed parameter: ", p, call. = FALSE)
    }
  }
  params
}

entries <- list()
for (b in blocks) {
  hdr <- grep("Rcpp::NumericVector\\s+([A-Za-z0-9_]+_opencl_cpp_export)\\s*\\(", b, value = TRUE)
  if (!length(hdr)) next
  export_name <- sub(
    "^.*Rcpp::NumericVector\\s+([A-Za-z0-9_]+_opencl_cpp_export).*",
    "\\1",
    hdr[[1L]]
  )
  ns_name <- sub("_cpp_export$", "", export_name)
  capi_name <- paste0("nmathopencl_", ns_name)
  params <- parse_params(b)
  call_line <- grep(paste0("return nmathopencl::", ns_name, "\\("), b, value = TRUE)[1L]
  if (is.na(call_line)) {
    stop("No nmathopencl:: call for ", export_name, call. = FALSE)
  }
  entries[[length(entries) + 1L]] <- list(
    export_name = export_name,
    ns_name = ns_name,
    capi_name = capi_name,
    params = params
  )
}

entries <- entries[order(vapply(entries, `[[`, "", "capi_name"))]
if (!length(entries)) stop("No *_opencl_cpp_export entries parsed.", call. = FALSE)

message("Parsed ", length(entries), " GPU nmath C API entries.")

gen_header_block <- function(entry) {
  n <- entry$capi_name
  pnames <- vapply(entry$params, `[[`, "", "name")
  SEXP_args <- paste(vapply(entry$params, `[[`, "", "SEXP"), pnames, sep = " ", collapse = ", ")
  fn_t <- paste0(n, "_t")
  c(
    paste0("  typedef SEXP (*", fn_t, ")(", SEXP_args, ");"),
    "",
    paste0("  static inline ", fn_t, " ", n, "_fn(void) {"),
    paste0("    static ", fn_t, " fn = NULL;"),
    paste0('    if (!fn) fn = (', fn_t, ')'),
    paste0('        nmathopencl_capi_resolve_("', n, '");'),
    "    return fn;",
    "  }",
    "",
    paste0("  static inline SEXP ", n, "("),
    if (length(pnames)) paste0("      ", SEXP_args) else "      void",
    "  ) {",
    if (length(pnames)) {
      paste0("    return ", n, "_fn()(", paste(pnames, collapse = ", "), ");")
    } else {
      paste0("    return ", n, "_fn()();")
    },
    "  }",
    ""
  )
}

gen_cpp_wrapper <- function(entry) {
  n <- entry$capi_name
  pnames <- vapply(entry$params, `[[`, "", "name")
  SEXP_args <- paste(vapply(entry$params, `[[`, "", "SEXP"), pnames, sep = " ", collapse = ", ")
  as_lines <- vapply(
    entry$params,
    function(p) paste0("        Rcpp::as<", p$as, ">(", p$name, ")"),
    ""
  )
  call_args <- paste(as_lines, collapse = ",\n")
  c(
    paste0("SEXP ", n, "(", SEXP_args, ") {"),
    "  try {",
    paste0("    return Rcpp::wrap(nmathopencl::", entry$ns_name, "("),
    call_args,
    "    ));",
    "  } catch (const std::exception& e) {",
    '    Rf_error("%s", e.what());',
    "  } catch (...) {",
    paste0('    Rf_error("', n, ' failed");'),
    "  }",
    "}",
    ""
  )
}

header_lines <- c(
  "/**",
  " * @file nmathopencl_capi.h",
  " * @brief C-callable API for GPU nmath/stats routines in nmathopencl.",
  " *",
  " * Installed for LinkingTo: nmathopencl (#include <nmathopencl/nmathopencl_capi.h>).",
  " * Generated by tools/generate_nmathopencl_capi.R — do not edit by hand.",
  " *",
  " * Requires Imports: nmathopencl (and opencltools at runtime for kernel loading).",
  " * LinkingTo: nmathopencl supplies -I only; no PKG_LIBS needed for C API use.",
  " */",
  "",
  "#ifndef NMATHOPENCL_CAPI_H",
  "#define NMATHOPENCL_CAPI_H",
  "",
  "#include <R_ext/Rdynload.h>",
  "#include <R_ext/Error.h>",
  "#include <R.h>",
  "",
  "/*",
  " * nmathopencl C-callable API (mirrors opencltools_capi.h layout).",
  " * All distribution/special routines use SEXP for R ABI stability.",
  " * Call nmathopencl_api_version() before relying on symbol sets.",
  " */",
  "",
  "#ifdef __cplusplus",
  "extern \"C\" {",
  "#endif",
  "",
  "  typedef int (*nmathopencl_api_version_t)(void);",
  "  typedef int (*nmathopencl_has_opencl_t)(void);",
  "",
  "  static inline DL_FUNC nmathopencl_capi_resolve_(const char* name) {",
  "    DL_FUNC p = R_GetCCallable(\"nmathopencl\", name);",
  "    if (!p) {",
  "      Rf_error(",
  "        \"nmathopencl C-callable '%s' not found; check package version/load order.\",",
  "        name);",
  "    }",
  "    return p;",
  "  }",
  "",
  "  static inline nmathopencl_api_version_t nmathopencl_api_version_fn(void) {",
  "    static nmathopencl_api_version_t fn = NULL;",
  "    if (!fn) fn = (nmathopencl_api_version_t)",
  "        nmathopencl_capi_resolve_(\"nmathopencl_api_version\");",
  "    return fn;",
  "  }",
  "",
  "  static inline int nmathopencl_api_version(void) {",
  "    return nmathopencl_api_version_fn()();",
  "  }",
  "",
  "  static inline nmathopencl_has_opencl_t nmathopencl_has_opencl_fn(void) {",
  "    static nmathopencl_has_opencl_t fn = NULL;",
  "    if (!fn) fn = (nmathopencl_has_opencl_t)",
  "        nmathopencl_capi_resolve_(\"nmathopencl_has_opencl\");",
  "    return fn;",
  "  }",
  "",
  "  static inline int nmathopencl_has_opencl(void) {",
  "    return nmathopencl_has_opencl_fn()();",
  "  }",
  ""
)

for (e in entries) {
  header_lines <- c(header_lines, gen_header_block(e))
}

header_lines <- c(
  header_lines,
  "#ifdef __cplusplus",
  "}",
  "#endif",
  "",
  "#endif /* NMATHOPENCL_CAPI_H */",
  ""
)

cpp_lines <- c(
  "/* Generated by tools/generate_nmathopencl_capi.R — do not edit by hand. */",
  "",
  "#include <R_ext/Rdynload.h>",
  "#include <R_ext/Error.h>",
  "#include <RcppArmadillo.h>",
  "#include \"nmathopencl.h\"",
  "#include \"openclPort.h\"",
  "",
  "extern \"C\" {",
  "",
  "int nmathopencl_api_version(void) {",
  "  return 1;",
  "}",
  "",
  "int nmathopencl_has_opencl(void) {",
  "  return openclPort::has_opencl() ? 1 : 0;",
  "}",
  ""
)

for (e in entries) {
  cpp_lines <- c(cpp_lines, gen_cpp_wrapper(e))
}

cpp_lines <- c(cpp_lines, "} // extern \"C\"", "", "")

reg_lines <- c(
  "// [[Rcpp::export]]",
  "void register_nmathopencl_ccallables_cpp_export() {",
  '  R_RegisterCCallable("nmathopencl", "nmathopencl_api_version",',
  "      (DL_FUNC) &nmathopencl_api_version);",
  '  R_RegisterCCallable("nmathopencl", "nmathopencl_has_opencl",',
  "      (DL_FUNC) &nmathopencl_has_opencl);"
)
for (e in entries) {
  reg_lines <- c(
    reg_lines,
    paste0('  R_RegisterCCallable("nmathopencl", "', e$capi_name, '",'),
    paste0("      (DL_FUNC) &", e$capi_name, ");")
  )
}
reg_lines <- c(reg_lines, "}", "")

cpp_lines <- c(cpp_lines, reg_lines)

out_header <- file.path(pkg_root, "inst", "include", "nmathopencl", "nmathopencl_capi.h")
out_cpp <- file.path(pkg_root, "src", "nmathopencl_ccallables.cpp")
dir.create(dirname(out_header), recursive = TRUE, showWarnings = FALSE)

writeLines(header_lines, out_header, useBytes = TRUE)
writeLines(cpp_lines, out_cpp, useBytes = TRUE)

message("Wrote ", out_header)
message("Wrote ", out_cpp)
