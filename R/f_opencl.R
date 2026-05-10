#' The F Distribution (OpenCL linkage subset)
#'
#' OpenCL-backed non-central F distribution and quantile wrappers.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param df1 Numerator degrees of freedom (must be > 0).
#' @param df2 Denominator degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' \code{qf_opencl()} can fail on some GPU/driver combinations with
#' \code{CL_OUT_OF_RESOURCES} in heavy non-central inversion paths
#' (\code{qnf -> qnbeta -> pnbeta} iterations). If reproducibility is critical,
#' prefer CPU fallback or small linkage-only smoke inputs.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_f_opencl.R
#' @rdname f_opencl
#' @export
pf_opencl <- function(n, x, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnf_opencl(n, x, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pf(x, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pf_opencl"
  )
}

#' @rdname f_opencl
#' @export
qf_opencl <- function(n, p, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnf_opencl(n, p, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qf(p, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qf_opencl"
  )
}

