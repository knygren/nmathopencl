#' The Beta Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the beta distribution. These mirror the base \code{stats} beta family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile in \code{[0, 1]}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param shape1 First shape parameter (must be > 0).
#' @param shape2 Second shape parameter (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0). Used by
#'   \code{pbeta_opencl()} and \code{qbeta_opencl()}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' \code{qbeta_opencl()} in the non-central path (\code{ncp > 0}, via
#' \code{qnbeta}) may be slow or hit device/runtime resource limits for difficult
#' parameter regions on some GPUs.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_beta_opencl.R
#' @rdname beta_opencl
#' @export
dbeta_opencl <- function(n, x, shape1, shape2, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, 1)
  .validate_scalar_num(shape1, "shape1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(shape2, "shape2", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dbeta_opencl(n, x, shape1, shape2, verbose = verbose),
    fallback_expr = function() rep(stats::dbeta(x, shape1 = shape1, shape2 = shape2), n),
    fallback = fallback, verbose = verbose, fn_name = "dbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
pbeta_opencl <- function(n, x, shape1, shape2, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, 1)
  .validate_scalar_num(shape1, "shape1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(shape2, "shape2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .pbeta_opencl(n, x, shape1, shape2, verbose = verbose)
      } else {
        .pnbeta_opencl(n, x, shape1, shape2, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::pbeta(x, shape1 = shape1, shape2 = shape2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
qbeta_opencl <- function(n, p, shape1, shape2, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(shape1, "shape1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(shape2, "shape2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .qbeta_opencl(n, p, shape1, shape2, verbose = verbose)
      } else {
        .qnbeta_opencl(n, p, shape1, shape2, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::qbeta(p, shape1 = shape1, shape2 = shape2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
rbeta_opencl <- function(n, shape1, shape2, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape1, "shape1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(shape2, "shape2", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rbeta_opencl(n, shape1, shape2, verbose = verbose),
    fallback_expr = function() stats::rbeta(n, shape1 = shape1, shape2 = shape2),
    fallback = fallback, verbose = verbose, fn_name = "rbeta_opencl"
  )
}

