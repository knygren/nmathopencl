#' The Chi-squared Distribution (OpenCL linkage subset)
#'
#' OpenCL-backed non-central chi-squared distribution and quantile wrappers.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param df Degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_chisq_opencl.R
#' @rdname chisq_opencl
#' @export
pchisq_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnchisq_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pchisq(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pchisq_opencl"
  )
}

#' @rdname chisq_opencl
#' @export
qchisq_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnchisq_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qchisq(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qchisq_opencl"
  )
}

