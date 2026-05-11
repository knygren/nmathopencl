#' The Hypergeometric Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the hypergeometric distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param m Number of white balls in the urn (must be >= 0).
#' @param n_black Number of black balls in the urn (must be >= 0).
#' @param k Number of draws (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_hypergeometric_opencl.R
#' @rdname hypergeometric_opencl
#' @export
dhyper_opencl <- function(n, x, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dhyper_opencl(n, x, m, n_black, k, verbose = verbose),
    fallback_expr = function() rep(stats::dhyper(x, m = m, n = n_black, k = k), n),
    fallback = fallback, verbose = verbose, fn_name = "dhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
phyper_opencl <- function(n, q, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .phyper_opencl(n, q, m, n_black, k, verbose = verbose),
    fallback_expr = function() rep(stats::phyper(q, m = m, n = n_black, k = k), n),
    fallback = fallback, verbose = verbose, fn_name = "phyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
qhyper_opencl <- function(n, p, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qhyper_opencl(n, p, m, n_black, k, verbose = verbose),
    fallback_expr = function() rep(stats::qhyper(p, m = m, n = n_black, k = k), n),
    fallback = fallback, verbose = verbose, fn_name = "qhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
rhyper_opencl <- function(n, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rhyper_opencl(n, m, n_black, k, verbose = verbose),
    fallback_expr = function() stats::rhyper(n, m = m, n = n_black, k = k),
    fallback = fallback, verbose = verbose, fn_name = "rhyper_opencl"
  )
}
