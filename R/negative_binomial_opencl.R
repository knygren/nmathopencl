#' The Negative Binomial Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the negative binomial distribution, with variants parameterized by
#' \code{prob} and by \code{mu}.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric scalar quantile (must be >= 0).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param size Dispersion/size parameter (must be >= 0).
#' @param prob Probability of success in \code{[0, 1]}.
#' @param mu Mean parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_negative_binomial_opencl.R
#' @rdname negative_binomial_opencl
#' @export
dnbinom_opencl <- function(n, x, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dnbinom_opencl(n, x, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::dnbinom(x, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
pnbinom_opencl <- function(n, q, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnbinom_opencl(n, q, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::pnbinom(q, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "pnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
qnbinom_opencl <- function(n, p, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbinom_opencl(n, p, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::qnbinom(p, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "qnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
rnbinom_opencl <- function(n, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rnbinom_opencl(n, size, prob, verbose = verbose),
    fallback_expr = function() stats::rnbinom(n, size = size, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
dnbinom_mu_opencl <- function(n, x, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dnbinom_mu_opencl(n, x, size, mu, verbose = verbose),
    fallback_expr = function() rep(stats::dnbinom(x, size = size, mu = mu), n),
    fallback = fallback, verbose = verbose, fn_name = "dnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
pnbinom_mu_opencl <- function(n, q, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnbinom_mu_opencl(n, q, size, mu, verbose = verbose),
    fallback_expr = function() rep(stats::pnbinom(q, size = size, mu = mu), n),
    fallback = fallback, verbose = verbose, fn_name = "pnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
qnbinom_mu_opencl <- function(n, p, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbinom_mu_opencl(n, p, size, mu, verbose = verbose),
    fallback_expr = function() rep(stats::qnbinom(p, size = size, mu = mu), n),
    fallback = fallback, verbose = verbose, fn_name = "qnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
rnbinom_mu_opencl <- function(n, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rnbinom_mu_opencl(n, size, mu, verbose = verbose),
    fallback_expr = function() stats::rnbinom(n, size = size, mu = mu),
    fallback = fallback, verbose = verbose, fn_name = "rnbinom_mu_opencl"
  )
}
