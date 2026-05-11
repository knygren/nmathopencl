#' The Student t Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Student t distribution.
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
#' @example inst/examples/Ex_t_opencl.R
#' @rdname t_opencl
#' @export
dt_opencl <- function(n, x, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .dt_opencl(n, x, df, verbose = verbose)
      } else {
        .dnt_opencl(n, x, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::dt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "dt_opencl"
  )
}

#' @rdname t_opencl
#' @export
pt_opencl <- function(n, x, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .pt_opencl(n, x, df, verbose = verbose)
      } else {
        .pnt_opencl(n, x, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::pt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pt_opencl"
  )
}

#' @rdname t_opencl
#' @export
qt_opencl <- function(n, p, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .qt_opencl(n, p, df, verbose = verbose)
      } else {
        .qnt_opencl(n, p, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::qt(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qt_opencl"
  )
}

#' @rdname t_opencl
#' @export
rt_opencl <- function(n, df, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rt_opencl(n, df, verbose = verbose),
    fallback_expr = function() stats::rt(n, df = df),
    fallback = fallback, verbose = verbose, fn_name = "rt_opencl"
  )
}

