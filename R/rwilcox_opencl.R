#' The Wilcoxon Rank Sum Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Wilcoxon rank sum distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param m Number of observations in one sample (must be > 0).
#' @param nn Number of observations in the other sample (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' Wilcoxon kernels can still hit runtime-shim gaps depending on device and
#' driver stack (for example unresolved runtime symbols in some builds).
#' Prefer \code{fallback = TRUE} for production paths.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_wilcox_opencl.R
#' @rdname wilcox_opencl
#' @export
dwilcox_opencl <- function(n, x, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dwilcox_opencl(n, x, m, nn, verbose = verbose),
    fallback_expr = function() rep(stats::dwilcox(x, m = m, n = nn), n),
    fallback = fallback, verbose = verbose, fn_name = "dwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
pwilcox_opencl <- function(n, q, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pwilcox_opencl(n, q, m, nn, verbose = verbose),
    fallback_expr = function() rep(stats::pwilcox(q, m = m, n = nn), n),
    fallback = fallback, verbose = verbose, fn_name = "pwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
qwilcox_opencl <- function(n, p, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qwilcox_opencl(n, p, m, nn, verbose = verbose),
    fallback_expr = function() rep(stats::qwilcox(p, m = m, n = nn), n),
    fallback = fallback, verbose = verbose, fn_name = "qwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
rwilcox_opencl <- function(n, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rwilcox_opencl(n, m = m, nn = nn, verbose = verbose),
    fallback_expr = function() stats::rwilcox(n, m = m, n = nn),
    fallback = fallback, verbose = verbose, fn_name = "rwilcox_opencl"
  )
}
