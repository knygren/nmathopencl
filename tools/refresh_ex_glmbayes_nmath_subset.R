# Refresh `inst/cl/ex_glmbayes_nmath` subset from kernels under
# `inst/cl/ex_glmbayes_src` using `inst/cl/nmath/kernel_dependency_index.rds`.
#
# Run from the package root, or pass the root explicitly:
#   Rscript tools/refresh_ex_glmbayes_nmath_subset.R
#   Rscript tools/refresh_ex_glmbayes_nmath_subset.R /path/to/nmathopencl
#
# Or: NMATHOPENCL_ROOT=/path/to/nmathopencl Rscript tools/refresh_ex_glmbayes_nmath_subset.R

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

pkg_dir <- resolve_pkg_dir()
if (!file.exists(file.path(pkg_dir, "DESCRIPTION"))) {
  stop("Not an R package root (no DESCRIPTION): ", pkg_dir, call. = FALSE)
}

if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("Install pkgload to run this script.", call. = FALSE)
}

suppressMessages(pkgload::load_all(pkg_dir, quiet = TRUE, compile = FALSE))

nmath_dir <- file.path(pkg_dir, "inst/cl/nmath")
src_dir   <- file.path(pkg_dir, "inst/cl/ex_glmbayes_src")
dest_dir  <- file.path(pkg_dir, "inst/cl/ex_glmbayes_nmath")

kern <- sort(list.files(src_dir, pattern = "\\.cl$", full.names = TRUE))
idx <- readRDS(file.path(nmath_dir, "kernel_dependency_index.rds"))

message("attach_cross_library_tags() …")
attach_cross_library_tags(
  kernel_paths = kern,
  library_dir = nmath_dir,
  depends_tag = "depends_nmath",
  index = idx,
  dry_run = FALSE
)

message("extract_library_subset() …")
subs <- extract_library_subset(
  kernel_paths = kern,
  library_dir = nmath_dir,
  dest_dir = dest_dir,
  depends_tag = "all_depends_nmath",
  index = idx,
  overwrite = TRUE
)
message("Copied / refreshed stems: ", nrow(subs))
print(subs[, c("stem", "copied")], row.names = FALSE)
message("done.")
