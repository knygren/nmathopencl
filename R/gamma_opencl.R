#' The Gamma Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the gamma distribution. These mirror the base \code{stats} gamma family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param x Numeric scalar quantile used by linkage wrappers.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param n Number of observations. Non-negative integer scalar.
#' @param shape Shape parameter (must be > 0).
#' @param scale Scale parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU \code{stats} function
#'   when OpenCL is unavailable or the OpenCL call fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector result from the corresponding gamma-family operation.
#' @example inst/examples/Ex_gamma_opencl.R
#' @rdname gamma_opencl
#' @export
dgamma_opencl <- function(n, x, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dgamma_opencl(n, x, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::dgamma(x, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "dgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
pgamma_opencl <- function(n, x, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pgamma_opencl(n, x, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::pgamma(x, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "pgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
qgamma_opencl <- function(n, p, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qgamma_opencl(n, p, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::qgamma(p, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "qgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
rgamma_opencl <- function(n, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rgamma_opencl(n, shape, scale, verbose = verbose),
    fallback_expr = function() stats::rgamma(n, shape = shape, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rgamma_opencl"
  )
}
