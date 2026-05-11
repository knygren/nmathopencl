#' OpenCL-backed Discrete linkage checks
#'
#' Linkage wrappers for selected discrete distribution helpers.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param p Probability in \code{[0, 1]}.
#' @param size Size/shape parameter (distribution specific; must be non-negative).
#' @param lambda Rate/intensity parameter for Poisson calls.
#' @param mu Mean parameter for \code{qnbinom_mu_opencl}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_discrete_opencl.R
#' @rdname discrete_opencl
#' @export
qpois_opencl <- function(n, p, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qpois_opencl(n, p, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::qpois(p, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "qpois_opencl"
  )
}

#' @rdname discrete_opencl
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

#' @rdname discrete_opencl
#' @export
rpois_opencl <- function(n, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rpois_opencl(n, lambda, verbose = verbose),
    fallback_expr = function() stats::rpois(n, lambda = lambda),
    fallback = fallback, verbose = verbose, fn_name = "rpois_opencl"
  )
}
