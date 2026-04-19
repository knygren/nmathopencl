# CRAN-oriented checks for glmbayes (maintainer script; excluded from package build).
#
# Prerequisites:
#   - Working directory = package root (directory containing DESCRIPTION).
#   - devtools installed.
#   - Win-builder calls need network access; ensure Maintainer email in DESCRIPTION is valid.
#
# Usage:
#   setwd("/path/to/glmbayes")   # or RStudio: project root
#   source("scripts/check-cran.R")

if (!file.exists("DESCRIPTION")) {
  stop("Set working directory to the glmbayes package root (where DESCRIPTION is).")
}

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("Install devtools: install.packages(\"devtools\")")
}

# Quick local check (fast feedback; no remote checks, no PDF manual).
devtools::check(cran = TRUE)

# Full CRAN-like pass: build vignettes and PDF manual to surface size/manual issues early.
# This is slower, but best reflects what CRAN will inspect in the source package.
devtools::check(vignettes = TRUE, args = "--as-cran", remote = TRUE, manual = TRUE)


# Submit source package to win-builder (results arrive by email; runs can be long).
# Comment out any of the following if you only want a subset.
devtools::check_win_release()
devtools::check_win_devel()
devtools::check_win_oldrelease()

# Submit source package to mac-builder (results arrive by email; runs can be long).
# Comment out any of the following if you only want a subset.
devtools::check_mac_release()
devtools::check_mac_devel()
devtools::check_mac_oldrelease()

# rhub::rhub_check() needs a GitHub token — set GITHUB_PAT in .Renviron or the shell, never in source.
if (!nzchar(Sys.getenv("GITHUB_PAT", ""))) {
  message("Skipping rhub::rhub_check(): set environment variable GITHUB_PAT (do not commit tokens).")
} else {
  rhub::rhub_check(platforms = c( "linux", "macos-arm64", "ubuntu-release", "ubuntu-next","atlas", "clang-asan", "valgrind","nosuggests","intel"))
}

# Optional: reproduce CRAN-like installed size locally (with vignettes).
# This sequence removes any existing local install, cleans stale object files,
# builds a source tarball with vignettes, installs from that tarball, and
# reports installed-size details.
# (There is no utils::package.size() in base R — sum file sizes under the install dir.)
#
# Keep this block commented until you want to run it.
#
# pkg_name <- "glmbayes"
# lib <- .libPaths()[1L]
# 
# if (pkg_name %in% rownames(installed.packages(lib.loc = lib, noCache = TRUE))) {
#   remove.packages(pkg_name, lib = lib)
# }
# 
# o_files <- list.files("src", pattern = "\\.o$", recursive = TRUE, full.names = TRUE)
# if (length(o_files)) {
#   unlink(o_files, force = TRUE)
# }
# 
# tarball <- devtools::build(vignettes = TRUE)
# install.packages(tarball, repos = NULL, type = "source", lib = lib)
# 
# pkg_dir <- file.path(lib, pkg_name)
# pkg_bytes <- sum(
#   file.info(list.files(pkg_dir, recursive = TRUE, full.names = TRUE))$size,
#   na.rm = TRUE
# )
# message(
#   "Installed package size: ",
#   round(pkg_bytes / 1024^2, 2), " MB (",
#   round(pkg_bytes / 1024, 1), " KB)"
# )
# subdirs <- list.dirs(pkg_dir, recursive = FALSE, full.names = TRUE)
# if (length(subdirs)) {
#   subdir_sizes <- sapply(
#     subdirs,
#     function(d) {
#       sum(file.info(list.files(d, recursive = TRUE, full.names = TRUE))$size, na.rm = TRUE)
#     }
#   )
#   print(sort(subdir_sizes, decreasing = TRUE))
# }
