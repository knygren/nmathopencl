#' Math Support Functions (OpenCL)
#'
#' OpenCL-backed wrappers for miscellaneous scalar support functions.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar input.
#' @param y Numeric scalar input.
#' @param digits Numeric scalar used by precision/rounding helpers.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_math_support_opencl.R
#' @rdname math_support_opencl
#' @export
imax2_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .imax2_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(as.numeric(max(as.integer(x), as.integer(y))), n),
    fallback = fallback, verbose = verbose, fn_name = "imax2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
imin2_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .imin2_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(as.numeric(min(as.integer(x), as.integer(y))), n),
    fallback = fallback, verbose = verbose, fn_name = "imin2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fmax2_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .fmax2_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(max(x, y), n),
    fallback = fallback, verbose = verbose, fn_name = "fmax2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fmin2_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .fmin2_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(min(x, y), n),
    fallback = fallback, verbose = verbose, fn_name = "fmin2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
sign_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .sign_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::sign(x), n),
    fallback = fallback, verbose = verbose, fn_name = "sign_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fprec_opencl <- function(n, x, digits, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(digits, "digits")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .fprec_opencl(n, x, digits, verbose = verbose),
    fallback_expr = function() rep(signif(x, digits = as.integer(digits)), n),
    fallback = fallback, verbose = verbose, fn_name = "fprec_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fround_opencl <- function(n, x, digits, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(digits, "digits")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .fround_opencl(n, x, digits, verbose = verbose),
    fallback_expr = function() rep(base::round(x, digits = as.integer(digits)), n),
    fallback = fallback, verbose = verbose, fn_name = "fround_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fsign_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .fsign_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(base::sign(x) * abs(y), n),
    fallback = fallback, verbose = verbose, fn_name = "fsign_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
ftrunc_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .ftrunc_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(base::trunc(x), n),
    fallback = fallback, verbose = verbose, fn_name = "ftrunc_opencl"
  )
}
