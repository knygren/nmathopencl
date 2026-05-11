#' The Exponential Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the exponential distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param rate Rate parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_exponential_opencl.R
#' @rdname exponential_opencl
#' @export
dexp_opencl <- function(n, x, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dexp_opencl(n, x, rate, verbose = verbose),
    fallback_expr = function() rep(stats::dexp(x, rate = rate), n),
    fallback = fallback, verbose = verbose, fn_name = "dexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
pexp_opencl <- function(n, q, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pexp_opencl(n, q, rate, verbose = verbose),
    fallback_expr = function() rep(stats::pexp(q, rate = rate), n),
    fallback = fallback, verbose = verbose, fn_name = "pexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
qexp_opencl <- function(n, p, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qexp_opencl(n, p, rate, verbose = verbose),
    fallback_expr = function() rep(stats::qexp(p, rate = rate), n),
    fallback = fallback, verbose = verbose, fn_name = "qexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
rexp_opencl <- function(n, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rexp_opencl(n, rate = rate, verbose = verbose),
    fallback_expr = function() stats::rexp(n, rate = rate),
    fallback = fallback, verbose = verbose, fn_name = "rexp_opencl"
  )
}
