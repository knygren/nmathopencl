#' The Cauchy Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Cauchy distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param location Location parameter.
#' @param scale Scale parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_cauchy_opencl.R
#' @rdname cauchy_opencl
#' @export
dcauchy_opencl <- function(n, x, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dcauchy_opencl(n, x, location, scale, verbose = verbose),
    fallback_expr = function() rep(stats::dcauchy(x, location = location, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "dcauchy_opencl"
  )
}

#' @rdname cauchy_opencl
#' @export
pcauchy_opencl <- function(n, q, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q")
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pcauchy_opencl(n, q, location, scale, verbose = verbose),
    fallback_expr = function() rep(stats::pcauchy(q, location = location, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "pcauchy_opencl"
  )
}

#' @rdname cauchy_opencl
#' @export
qcauchy_opencl <- function(n, p, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qcauchy_opencl(n, p, location, scale, verbose = verbose),
    fallback_expr = function() rep(stats::qcauchy(p, location = location, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "qcauchy_opencl"
  )
}

#' @rdname cauchy_opencl
#' @export
rcauchy_opencl <- function(n, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rcauchy_opencl(n, location, scale, verbose = verbose),
    fallback_expr = function() stats::rcauchy(n, location = location, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rcauchy_opencl"
  )
}
