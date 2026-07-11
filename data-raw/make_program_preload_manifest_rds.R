#!/usr/bin/env Rscript

## Regenerate inst/cl/program_preload_manifest.rds beside the shipped TSV.
## Run from the nmathopencl package root after opencltools is installed or
## available via pkgload::load_all().

if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("pkgload required to build program_preload_manifest.rds")
}

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
pkg_root <- if (length(file_arg)) {
  normalizePath(file.path(dirname(sub("^--file=", "", file_arg)), ".."), winslash = "/")
} else {
  normalizePath(".", winslash = "/")
}

tsv_path <- file.path(pkg_root, "inst", "cl", "program_preload_manifest.tsv")
if (!file.exists(tsv_path)) {
  stop("Missing manifest TSV: ", tsv_path)
}

opencltools_path <- Sys.getenv("OPENCLTOOLS_ROOT", unset = "")
if (nzchar(opencltools_path) && dir.exists(opencltools_path)) {
  pkgload::load_all(opencltools_path, quiet = TRUE)
} else if (!requireNamespace("opencltools", quietly = TRUE)) {
  stop("opencltools required to build program_preload_manifest.rds")
}

opencltools::write_program_preload_manifest(
  manifest_path = tsv_path,
  source_package = "nmathopencl",
  write = TRUE,
  verbose = TRUE
)

message("Done.")
