#' @aliases nmathopencl
#'
#' @title nmathopencl: OpenCL-Ported R Math Library for GPU-Accelerated Packages
#'
#' @description
#' `nmathopencl` provides OpenCL-ported versions of R's internal `nmath` and
#' `R_ext` math routines, enabling downstream R packages to build custom
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
#' worked example of how a downstream package—here the `glmbayes` Bayesian GLM
#' sampler—builds a custom kernel on top of the ported nmath routines. See
#' \code{system.file("examples", "Ex_EnvelopeEval.R", package = "nmathopencl")}
#' and the vignette \emph{GPU Acceleration} for a complete walkthrough.
#'
#' Optional GPU acceleration is available wherever an OpenCL runtime is
#' installed. Use \code{\link{has_opencl}} to query availability at runtime and
#' \code{\link{diagnose_glmbayes}} for detailed device diagnostics.
#'
#' The simulation theory underlying the envelope construction is described in
#' \insertCite{Nygren2006}{nmathopencl}, with implementation details in
#' \insertCite{glmbayesSimmethods,glmbayesChapterA08}{nmathopencl}.
#' GPU/OpenCL topics are covered in
#' \insertCite{glmbayesChapter12,glmbayesChapterA10}{nmathopencl}.
#'
#' @seealso
#' Key developer entry points:
#' \itemize{
#'   \item \code{\link{load_kernel_library}} — assemble the nmath `.cl` sources
#'     into an OpenCL program string.
#'   \item \code{\link{has_opencl}} — check whether an OpenCL runtime is present.
#'   \item \code{\link{Ex_EnvelopeEval}} — worked example of a custom kernel built
#'     on the ported nmath routines.
#' }
#'
#' Useful links:
#' \itemize{
#'   \item GitHub: <https://github.com/knygren/glmbayes>
#'   \item R-Universe: <https://knygren.r-universe.dev/glmbayes>
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
#' @useDynLib nmathopencl, .registration = TRUE
"_PACKAGE"
