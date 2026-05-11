#' The Poisson Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Poisson distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param lambda Mean/rate parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_poisson_opencl.R
#' @rdname poisson_opencl
#' @export
dpois_raw_opencl <- function(n, x, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dpois_raw_opencl(n, x, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::dpois(x, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "dpois_raw_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
dpois_opencl <- function(n, x, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dpois_opencl(n, x, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::dpois(x, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "dpois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
ppois_opencl <- function(n, q, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .ppois_opencl(n, q, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::ppois(q, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "ppois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
qpois_opencl <- function(n, p, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qpois_opencl(n, p, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::qpois(p, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "qpois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
rpois_opencl <- function(n, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rpois_opencl(n, lambda, verbose = verbose),
    fallback_expr = function() stats::rpois(n, lambda = lambda),
    fallback = fallback, verbose = verbose, fn_name = "rpois_opencl"
  )
}
