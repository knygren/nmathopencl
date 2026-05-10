#' The Beta Distribution (OpenCL linkage subset)
#'
#' OpenCL-backed distribution and quantile wrappers for beta-family linkage checks.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile in \code{[0, 1]}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param a Shape1 parameter (must be > 0).
#' @param b Shape2 parameter (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' \code{qbeta_opencl()} (non-central path via \code{qnbeta}) may be slow or hit
#' device/runtime resource limits for difficult parameter regions on some GPUs.
#' Use small linkage-smoke inputs when validating kernel wiring.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_beta_opencl.R
#' @rdname beta_opencl
#' @export
pbeta_opencl <- function(n, x, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnbeta_opencl(n, x, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pbeta(x, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
qbeta_opencl <- function(n, p, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbeta_opencl(n, p, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qbeta(p, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qbeta_opencl"
  )
}

