# Re-exports from opencltools (Tier 4: kernel library authoring / subset loading).
# Tier 3 runtime/system diagnostics live in opencltools only; call opencltools::.

#' @export
#' @inherit opencltools::attach_kernel_call_tags
attach_kernel_call_tags <- opencltools::attach_kernel_call_tags

#' @export
#' @inherit opencltools::attach_kernel_dependency_tags
attach_kernel_dependency_tags <- opencltools::attach_kernel_dependency_tags

#' @export
#' @inherit opencltools::attach_cross_library_tags
attach_cross_library_tags <- opencltools::attach_cross_library_tags

#' @export
#' @inherit opencltools::write_kernel_dependency_index
write_kernel_dependency_index <- opencltools::write_kernel_dependency_index

#' @export
#' @inherit opencltools::stage_kernel_dependency_sort
stage_kernel_dependency_sort <- opencltools::stage_kernel_dependency_sort

#' @export
#' @inherit opencltools::extract_library_subset
extract_library_subset <- opencltools::extract_library_subset

#' @export
#' @inherit opencltools::load_library_for_kernel
load_library_for_kernel <- opencltools::load_library_for_kernel

#' @export
#' @inherit opencltools::use_opencl_configure
use_opencl_configure <- opencltools::use_opencl_configure

#' @export
#' @inherit opencltools::port_to_opencl_configure title description params return examples seealso
#' @section src/Makevars.in workflow:
#' After porting, \strong{maintain \code{src/Makevars.in}} for your base build
#' flags (\code{OpenMP}, \pkg{RcppParallel}, LAPACK, etc.).  The configure
#' script reads it at install time and appends (or omits) the OpenCL flags.
#' The generated \code{src/Makevars} is a build artifact -- add it to
#' \code{.gitignore} and never commit it.  To update base flags, edit
#' \code{src/Makevars.in} and reinstall.
#' @section configure -> USE_OPENCL -> has_opencl():
#' \preformatted{
#'   configure / configure.win
#'     -> reads src/Makevars.in for base flags
#'     -> detects CL/cl.h + libOpenCL (+ runtime probe on Linux)
#'     -> writes -DUSE_OPENCL into Makevars  (or copies .in verbatim)
#'
#'   #ifdef USE_OPENCL in C++ source
#'     -> guards all GPU code; package compiles cleanly either way
#'
#'   has_opencl() in R
#'     -> mirrors the compile-time flag; TRUE only if USE_OPENCL was set
#' }
#' @section Limitations:
#' \itemize{
#' \item \code{+=} (append) assignments in \code{src/Makevars} are detected
#'   and trigger a warning; review the generated configure carefully.
#' \item If \code{src/Makevars} looks like a generated file (contains
#'   absolute paths, \code{-lOpenCL}, or \code{-DUSE_OPENCL}), the function
#'   warns.  Run on the static committed file, not a build artifact.
#' \item Packages that already have \code{configure} or \code{configure.win}
#'   are refused unless \code{overwrite = TRUE}.  Users with existing
#'   configure scripts should integrate the OpenCL block manually; see
#'   \code{system.file("configure-templates", "README.md",
#'     package = "opencltools")}.
#' }
port_to_opencl_configure <- opencltools::port_to_opencl_configure
