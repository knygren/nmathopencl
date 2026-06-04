#' @aliases nmathopencl
#'
#' @title nmathopencl: OpenCL-Ported R Math Library for GPU-Accelerated Packages
#'
#' @description
#' \pkg{nmathopencl} provides OpenCL-ported versions of R's internal \code{nmath} and
#' \code{R_ext} math routines, enabling downstream R packages to build custom
#' GPU-accelerated kernels that call the same statistical distribution functions
#' available in base R. The package is intended as a **developer library**: users
#' install it to gain access to the ported `.cl` source files, then write their
#' own OpenCL kernels that `#include` those sources as needed.
#'
#' @details
#' The core deliverable is a collection of `.cl` files installed under
#' `inst/cl/nmath/` that mirror the R `nmath` library (density, distribution,
#' quantile, and random-variate functions). Downstream packages locate these
#' files at runtime with `system.file("cl", package = "nmathopencl")` and
#' assemble them into an OpenCL program using `load_kernel_library()`.
#'
#' The package also ships \code{\link{Ex_EnvelopeEval}} and its supporting
#' functions (`Ex_glmbfamfunc`, `Ex_glmb_Standardize_Model`, `Ex_EnvelopeSize`) as a
#' worked example of how a downstream package—here the \pkg{glmbayes} Bayesian GLM
#' sampler—builds a custom kernel on top of the ported nmath routines. See
#' \code{system.file("examples", "Ex_EnvelopeEval.R", package = "nmathopencl")}
#' and \code{vignette("Chapter-10")} for a complete walkthrough.
#'
#' Optional GPU acceleration is available wherever an OpenCL runtime is
#' installed. Use \code{\link{has_opencl}} to query compile-time OpenCL support,
#' \code{\link{opencl_fp64_available}} / \code{\link{opencl_device_info}} for
#' double-precision device selection used by kernels, and
#' \code{\link{diagnose_glmbayes}} for detailed device diagnostics.
#'
#' The simulation theory underlying the envelope construction is described in
#' \insertCite{Nygren2006}{nmathopencl}, with implementation details in
#' \insertCite{glmbayesSimmethods,glmbayesChapterA08}{nmathopencl}.
#' OpenCL GPU execution follows \insertCite{Stone2010}{nmathopencl}; package
#' vignettes also discuss GPU workflows
#' (\insertCite{glmbayesChapter12,glmbayesChapterA10}{nmathopencl}).
#'
#' @section OpenCL startup checks:
#' In interactive sessions, attaching the package with \code{library(nmathopencl)}
#' may emit a \code{\link{packageStartupMessage}}
#' comparing compile-time OpenCL support in \pkg{nmathopencl} and
#' \pkg{opencltools}, noting that CPU fallbacks remain available, and
#' summarizing whether an OpenCL runtime appears available on the host.
#' Messages point to \code{?gpu_diagnostics}, \code{vignette("Chapter-01")}
#' (OpenCL enablement), \code{vignette("Chapter-12")} (packaged \code{*_opencl}
#' API), and this help page. Host-side OpenCL diagnostics use \pkg{opencltools}.
#' Set \code{options(nmathopencl.quiet_opencl_startup = TRUE)} to suppress
#' these notes (recommended for CI and \command{R CMD check}).
#'
#' @seealso
#' Key developer entry points:
#' \itemize{
#'   \item \code{\link{load_kernel_library}} — assemble the nmath `.cl` sources
#'     into an OpenCL program string.
#'   \item \code{\link{has_opencl}} — check whether an OpenCL runtime is present.
#'   \item \code{\link{opencl_device_info}} --- which OpenCL device is used for fp64 kernels.
#'   \item \code{\link{Ex_EnvelopeEval}} — worked example of a custom kernel built
#'     on the ported nmath routines.
#' }
#'
#' Useful links:
#' \itemize{
#'   \item GitHub: <https://github.com/knygren/nmathopencl>
#'   \item R-Universe: <https://knygren.r-universe.dev/nmathopencl>
#'   \item Related sampler package (Suggests): \pkg{glmbayes}
#' }
#'
#' @references
#' \insertAllCited{}
#'
#' @author
#' Kjell Nygren
#'
#' @import stats Rcpp
#' @importFrom Rcpp evalCpp
#' @importFrom MASS mvrnorm
#' @importFrom Rdpack reprompt
#' @importFrom RcppParallel RcppParallelLibs
#' @importFrom opencltools load_kernel_source load_kernel_library load_library_for_kernel
#' @importFrom opencltools extract_library_subset write_kernel_dependency_index
#' @importFrom opencltools stage_kernel_dependency_sort attach_kernel_dependency_tags
#' @importFrom opencltools attach_kernel_call_tags attach_cross_library_tags
#' @importFrom opencltools use_opencl_configure port_to_opencl_configure
#' @useDynLib nmathopencl, .registration = TRUE
"_PACKAGE"
