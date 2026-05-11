#' The Binomial Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the binomial distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param size Number of trials (must be >= 0).
#' @param prob Probability of success in \code{[0, 1]}.
#' @param qprob Complementary probability. If \code{NULL}, uses \code{1 - prob}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_binomial_opencl.R
#' @rdname binomial_opencl
#' @export
dbinom_raw_opencl <- function(n, x, size, prob, qprob = NULL, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  if (is.null(qprob)) {
    qprob <- 1 - prob
  }
  .validate_scalar_num(qprob, "qprob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dbinom_raw_opencl(n, x, size, prob, qprob, verbose = verbose),
    fallback_expr = function() rep(stats::dbinom(x, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dbinom_raw_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
dbinom_opencl <- function(n, x, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dbinom_opencl(n, x, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::dbinom(x, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
pbinom_opencl <- function(n, q, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pbinom_opencl(n, q, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::pbinom(q, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "pbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
qbinom_opencl <- function(n, p, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qbinom_opencl(n, p, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::qbinom(p, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "qbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
rbinom_opencl <- function(n, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rbinom_opencl(n, size, prob, verbose = verbose),
    fallback_expr = function() stats::rbinom(n, size = size, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rbinom_opencl"
  )
}
