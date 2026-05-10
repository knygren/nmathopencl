#' The Student t Distribution (OpenCL linkage subset)
#'
#' OpenCL-backed non-central Student t distribution and quantile wrappers.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param df Degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @rdname t_opencl
#' @export
pt_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnt_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pt_opencl"
  )
}

#' @rdname t_opencl
#' @export
qt_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnt_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qt(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qt_opencl"
  )
}

# Backward-compatible aliases (old Mathlib-style names)
pnt_opencl <- function(...) pt_opencl(...)
qnt_opencl <- function(...) qt_opencl(...)
