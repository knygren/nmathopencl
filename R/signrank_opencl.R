#' The Wilcoxon Signed Rank Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Wilcoxon signed rank distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param nsize Number of observations used by signed-rank routines (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' Signed-rank kernels can fail to build on some GPU toolchains due to unresolved
#' runtime allocation symbols (for example \code{R_chk_calloc}). Keep
#' \code{fallback = TRUE} for production use until device-safe allocator shims are
#' complete.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_signrank_opencl.R
#' @rdname signrank_opencl
#' @export
dsignrank_opencl <- function(n, x, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dsignrank_opencl(n, x, nsize, verbose = verbose),
    fallback_expr = function() rep(stats::dsignrank(x, n = nsize), n),
    fallback = fallback, verbose = verbose, fn_name = "dsignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
psignrank_opencl <- function(n, q, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .psignrank_opencl(n, q, nsize, verbose = verbose),
    fallback_expr = function() rep(stats::psignrank(q, n = nsize), n),
    fallback = fallback, verbose = verbose, fn_name = "psignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
qsignrank_opencl <- function(n, p, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qsignrank_opencl(n, p, nsize, verbose = verbose),
    fallback_expr = function() rep(stats::qsignrank(p, n = nsize), n),
    fallback = fallback, verbose = verbose, fn_name = "qsignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
rsignrank_opencl <- function(n, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rsignrank_opencl(n, nsize, verbose = verbose),
    fallback_expr = function() stats::rsignrank(n, n = nsize),
    fallback = fallback, verbose = verbose, fn_name = "rsignrank_opencl"
  )
}
