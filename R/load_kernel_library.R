#' Load OpenCL Kernel Source Files
#'
#' These functions provide a user-facing interface for loading OpenCL kernel
#' source files and kernel libraries from the package's `cl/` directory.
#' They call internal C++ routines that perform file lookup, dependency
#' resolution, and concatenation of kernel sources.
#'
#' OpenCL support is optional. If the package was built without OpenCL
#' (e.g., on systems lacking OpenCL headers or drivers), these functions
#' return a clear error message.
#'
#' @section OpenCL Availability:
#' Use \code{\link{has_opencl}} to check whether OpenCL support is available
#' in the current build of \pkg{glmbayes}.
#'
#' @param relative_path A file path inside the package's `cl/` directory.
#'   Used by \code{load_kernel_source()} to load a single `.cl` file.
#' @param subdir A subdirectory inside `cl/` containing a set of `.cl` files
#'   annotated with \code{@provides} and \code{@depends} tags. Used by
#'   \code{load_kernel_library()} to construct a dependency-resolved kernel
#'   library.
#' @param package Package name (default: \code{"glmbayes"}).
#' @param verbose Logical; print diagnostic information during dependency
#'   resolution (default: \code{FALSE}).
#'
#' @return
#' A character string containing the kernel source code or combined kernel
#' library.
#'
#' @examples
#' \dontrun{
#' if (has_opencl()) {
#'   src <- load_kernel_source("nmath/bd0.cl")
#'   lib <- load_kernel_library("nmath")
#' }
#' }
#'
#' @export
load_kernel_source <- function(relative_path, package = "glmbayes") {
  if (!has_opencl()) {
    stop("OpenCL support is not available in this build of glmbayes.")
  }
  .load_kernel_source_wrapper(relative_path, package)
}

#' @rdname load_kernel_source
#' @export
load_kernel_library <- function(subdir, package = "glmbayes", verbose = FALSE) {
  if (!has_opencl()) {
    stop("OpenCL support is not available in this build of glmbayes.")
  }
  .load_kernel_library_wrapper(subdir, package, verbose)
}
