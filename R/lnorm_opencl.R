#' The Lognormal Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the lognormal distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param meanlog Mean of the distribution on the log scale.
#' @param sdlog Standard deviation on the log scale (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_lnorm_opencl.R
#' @rdname lnorm_opencl
#' @export
dlnorm_opencl <- function(n, x, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dlnorm_opencl(n, x, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() rep(stats::dlnorm(x, meanlog = meanlog, sdlog = sdlog), n),
    fallback = fallback, verbose = verbose, fn_name = "dlnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
plnorm_opencl <- function(n, q, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .plnorm_opencl(n, q, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() rep(stats::plnorm(q, meanlog = meanlog, sdlog = sdlog), n),
    fallback = fallback, verbose = verbose, fn_name = "plnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
qlnorm_opencl <- function(n, p, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qlnorm_opencl(n, p, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() rep(stats::qlnorm(p, meanlog = meanlog, sdlog = sdlog), n),
    fallback = fallback, verbose = verbose, fn_name = "qlnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
rlnorm_opencl <- function(n, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rlnorm_opencl(n, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() stats::rlnorm(n, meanlog = meanlog, sdlog = sdlog),
    fallback = fallback, verbose = verbose, fn_name = "rlnorm_opencl"
  )
}
