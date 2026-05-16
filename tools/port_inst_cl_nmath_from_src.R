# Regenerate inst/cl/nmath/*.cl from top-level src/nmath/*.c|*.h using openclport.
#
# Overwrites stems that exist in src/nmath. Extra .cl files under inst/cl/nmath
# that lack a ported source twin are left unchanged (manual splits / shims).
#
# Run from the package root, or pass the root explicitly:
#   Rscript tools/port_inst_cl_nmath_from_src.R
#   Rscript tools/port_inst_cl_nmath_from_src.R /path/to/nmathopencl
#
# Or: NMATHOPENCL_ROOT=/path/to/nmathopencl Rscript ...
#
# openclport is loaded from sibling ../openclport or OPENCLPORT_ROOT.
#
# **header_symbol_depends:** Uses `header_symbol_depends = FALSE` because token
# scans on umbrella headers (`nmath.h`) infer edges to nearly every `.c` stem and
# break dependency sorting. Add callee stems manually on sparse headers when
# needed (for example `qDiscrete_search.cl` -> `qnorm`). OpenCL port still maps
# API names like `qnorm` onto numbered exports (`qnorm5`) for `@provides`.

suppressPackageStartupMessages({
  if (!requireNamespace("pkgload", quietly = TRUE)) {
    stop("Install pkgload to run this script (devtools supplies it).", call. = FALSE)
  }
})

resolve_pkg_dir <- function() {
  cand <- Sys.getenv("NMATHOPENCL_ROOT", "")
  if (nzchar(cand)) {
    return(normalizePath(cand, winslash = "/", mustWork = TRUE))
  }

  argv <- suppressWarnings(commandArgs(trailingOnly = TRUE))
  argv <- argv[nzchar(argv)]
  if (length(argv) >= 1L) {
    return(normalizePath(argv[[1L]], winslash = "/", mustWork = TRUE))
  }

  args <- commandArgs(trailingOnly = FALSE)
  farg <- grep("^--file=", args, value = TRUE)
  if (length(farg) == 1L) {
    tool_path <- sub("^--file=", "", farg[1L])
    tool_path <- normalizePath(tool_path, winslash = "/", mustWork = TRUE)
    return(normalizePath(
      file.path(dirname(tool_path), ".."),
      winslash = "/",
      mustWork = TRUE
    ))
  }

  wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  if (basename(wd) == "tools") {
    return(normalizePath(file.path(wd, ".."), winslash = "/", mustWork = TRUE))
  }

  wd
}

resolve_openclport_root <- function(pkg_dir) {
  cand <- Sys.getenv("OPENCLPORT_ROOT", "")
  if (nzchar(cand)) {
    root <- normalizePath(cand, winslash = "/", mustWork = TRUE)
    if (!file.exists(file.path(root, "DESCRIPTION"))) {
      stop("OPENCLPORT_ROOT is not an R package: ", root, call. = FALSE)
    }
    return(root)
  }

  sibling <- normalizePath(file.path(pkg_dir, "..", "openclport"),
                           winslash = "/", mustWork = FALSE)
  if (!identical(sibling, "") && file.exists(file.path(sibling, "DESCRIPTION"))) {
    return(sibling)
  }

  stop(
    "Cannot find openclport. Set OPENCLPORT_ROOT ",
    "or place openclport as a sibling directory of nmathopencl.",
    "\n(pkg_dir=", pkg_dir, ")",
    call. = FALSE
  )
}

pkg_dir <- resolve_pkg_dir()
if (!file.exists(file.path(pkg_dir, "DESCRIPTION"))) {
  stop("Not an R package root (no DESCRIPTION): ", pkg_dir, call. = FALSE)
}

opc_root <- resolve_openclport_root(pkg_dir)
suppressMessages(pkgload::load_all(opc_root, quiet = TRUE, compile = FALSE))

message("Port src/nmath -> inst/cl/nmath (openclport: ", opc_root, ") …")
report <- port_kernel_library_subdirs(
  pkg_root = pkg_dir,
  source_subdir = file.path("src", "nmath"),
  target_subdir = file.path("inst", "cl", "nmath"),
  include_policy = "comment",
  overwrite = TRUE,
  macro_hygiene = "c_translation_unit",
  header_symbol_depends = FALSE
)
message("Ported ", nrow(report), " file(s); see data frame `report` when sourcing interactively.")
