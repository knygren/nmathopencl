#' The Studentized Range Distribution (OpenCL)
#'
#' OpenCL-backed distribution and quantile wrappers for the studentized range
#' (Tukey) distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param nmeans Number of means in each range (must be >= 2).
#' @param df Degrees of freedom (must be > 0).
#' @param nranges Number of groups whose maxima/minima define the range (must be >= 1).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_tukey_opencl.R
#' @rdname tukey_opencl
#' @export
ptukey_opencl <- function(n, q, nmeans, df, nranges = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(nmeans, "nmeans", 2, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nranges, "nranges", 1, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .ptukey_opencl(n, q, nmeans, df, nranges, verbose = verbose),
    fallback_expr = function() rep(stats::ptukey(q, nmeans = nmeans, df = df, nranges = nranges), n),
    fallback = fallback, verbose = verbose, fn_name = "ptukey_opencl"
  )
}

#' @rdname tukey_opencl
#' @export
qtukey_opencl <- function(n, p, nmeans, df, nranges = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(nmeans, "nmeans", 2, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nranges, "nranges", 1, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qtukey_opencl(n, p, nmeans, df, nranges, verbose = verbose),
    fallback_expr = function() rep(stats::qtukey(p, nmeans = nmeans, df = df, nranges = nranges), n),
    fallback = fallback, verbose = verbose, fn_name = "qtukey_opencl"
  )
}
