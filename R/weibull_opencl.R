#' The Weibull Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Weibull distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param shape Shape parameter (must be > 0).
#' @param scale Scale parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_weibull_opencl.R
#' @rdname weibull_opencl
#' @export
dweibull_opencl <- function(n, x, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dweibull_opencl(n, x, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::dweibull(x, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "dweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
pweibull_opencl <- function(n, q, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pweibull_opencl(n, q, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::pweibull(q, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "pweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
qweibull_opencl <- function(n, p, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qweibull_opencl(n, p, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::qweibull(p, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "qweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
rweibull_opencl <- function(n, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rweibull_opencl(n, shape, scale, verbose = verbose),
    fallback_expr = function() stats::rweibull(n, shape = shape, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rweibull_opencl"
  )
}
