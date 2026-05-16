# Refresh @all_depends_nmath / @all_depends_nmath_count on inst/cl/src kernels from
# the current inst/cl/nmath/kernel_dependency_index.rds.
#
# C++: [build_rmath_program_indexed()] (kernel_wrappers.cpp) loads partial nmath from
# these tags via load_library_for_kernel(), except full-tree load when tags list
# `qDiscrete_search` or the launcher is `norm_rand_kernel.cl` (see kernel_wrappers.cpp).
#
# Run from the package root, or pass the root explicitly:
#   Rscript tools/refresh_src_kernel_nmath_tags.R
#   Rscript tools/refresh_src_kernel_nmath_tags.R /path/to/nmathopencl
#
# Or: NMATHOPENCL_ROOT=/path/to/nmathopencl Rscript tools/refresh_src_kernel_nmath_tags.R

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
  stop(
    "Not an R package root (no DESCRIPTION): ", pkg_dir,
    "\nSet NMATHOPENCL_ROOT or pass the path as the first argument.",
    call. = FALSE
  )
}

pkgload::load_all(pkg_dir, quiet = TRUE, compile = FALSE)

nmath_dir <- file.path(pkg_dir, "inst/cl/nmath")
src_dir   <- file.path(pkg_dir, "inst/cl/src")

idx_path <- file.path(nmath_dir, "kernel_dependency_index.rds")
if (!file.exists(idx_path)) {
  stop(
    "Missing index: ", idx_path,
    "\nRun write_kernel_dependency_index(nmath_dir) first.",
    call. = FALSE
  )
}

kern <- sort(list.files(src_dir, pattern = "\\.cl$", full.names = TRUE))
if (length(kern) == 0L) {
  stop("No .cl kernels under ", src_dir, call. = FALSE)
}

idx <- readRDS(idx_path)

message("attach_cross_library_tags() on ", length(kern), " kernel(s) …")
res <- attach_cross_library_tags(
  kernel_paths = kern,
  library_dir = nmath_dir,
  depends_tag = "depends_nmath",
  index = idx,
  dry_run = FALSE
)

changed <- res[res[["changed"]] %in% TRUE, ]

message("Processed: ", nrow(res), "; updated: ", nrow(changed))

if (nrow(changed) > 0L) {
  print(changed[, c("file", "all_depends_count", "changed")], row.names = FALSE)
}

message("done.")
