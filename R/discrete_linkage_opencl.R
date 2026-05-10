#' OpenCL-backed qbinom linkage check
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

#' OpenCL-backed qpois linkage check
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

#' OpenCL-backed qnbinom_mu linkage check
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

#' OpenCL-backed rpois linkage check
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
