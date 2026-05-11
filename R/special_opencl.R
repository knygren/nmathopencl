#' Special Functions (OpenCL)
#'
#' OpenCL-backed wrappers for selected special functions from R Mathlib.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar input.
#' @param deriv Derivative order for \code{psigamma}.
#' @param a First scalar parameter.
#' @param b Second scalar parameter.
#' @param k Second argument for choose-style functions.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_special_opencl.R
#' @rdname special_opencl
#' @export
gammafn_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .gammafn_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::gamma(x), n),
    fallback = fallback, verbose = verbose, fn_name = "gammafn_opencl"
  )
}

#' @rdname special_opencl
#' @export
lgammafn_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .lgammafn_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::lgamma(x), n),
    fallback = fallback, verbose = verbose, fn_name = "lgammafn_opencl"
  )
}

#' @rdname special_opencl
#' @export
digamma_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .digamma_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::digamma(x), n),
    fallback = fallback, verbose = verbose, fn_name = "digamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
trigamma_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .trigamma_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::trigamma(x), n),
    fallback = fallback, verbose = verbose, fn_name = "trigamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
tetragamma_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .tetragamma_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::psigamma(x, deriv = 2), n),
    fallback = fallback, verbose = verbose, fn_name = "tetragamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
pentagamma_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pentagamma_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::psigamma(x, deriv = 3), n),
    fallback = fallback, verbose = verbose, fn_name = "pentagamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
psigamma_opencl <- function(n, x, deriv, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(deriv, "deriv", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .psigamma_opencl(n, x, deriv, verbose = verbose),
    fallback_expr = function() rep(base::psigamma(x, deriv = deriv), n),
    fallback = fallback, verbose = verbose, fn_name = "psigamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
beta_opencl <- function(n, a, b, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(a, "a")
  .validate_scalar_num(b, "b")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .beta_opencl(n, a, b, verbose = verbose),
    fallback_expr = function() rep(base::beta(a, b), n),
    fallback = fallback, verbose = verbose, fn_name = "beta_opencl"
  )
}

#' @rdname special_opencl
#' @export
lbeta_opencl <- function(n, a, b, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(a, "a")
  .validate_scalar_num(b, "b")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .lbeta_opencl(n, a, b, verbose = verbose),
    fallback_expr = function() rep(base::lbeta(a, b), n),
    fallback = fallback, verbose = verbose, fn_name = "lbeta_opencl"
  )
}

#' @rdname special_opencl
#' @export
choose_opencl <- function(n, x, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(k, "k")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .choose_opencl(n, x, k, verbose = verbose),
    fallback_expr = function() rep(base::choose(x, k), n),
    fallback = fallback, verbose = verbose, fn_name = "choose_opencl"
  )
}

#' @rdname special_opencl
#' @export
lchoose_opencl <- function(n, x, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(k, "k")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .lchoose_opencl(n, x, k, verbose = verbose),
    fallback_expr = function() rep(base::lchoose(x, k), n),
    fallback = fallback, verbose = verbose, fn_name = "lchoose_opencl"
  )
}
