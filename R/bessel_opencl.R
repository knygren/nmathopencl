#' Bessel Functions (OpenCL)
#'
#' OpenCL-backed wrappers for Bessel functions.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar input.
#' @param nu Order of the Bessel function.
#' @param expon.scaled Logical; whether to return the exponentially scaled value.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' Current Bessel OpenCL paths may require temporary-workspace allocation
#' semantics equivalent to host \code{R_alloc}/\code{vmax*} behavior. On some
#' GPU stacks this can fail at runtime; keep \code{fallback = TRUE} for
#' production use until device-side workspace handling is fully implemented.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_bessel_opencl.R
#' @rdname bessel_opencl
#' @export
besselI_opencl <- function(n, x, nu, expon.scaled = FALSE, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(nu, "nu")
  .validate_flag(expon.scaled, "expon.scaled")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  expo <- if (isTRUE(expon.scaled)) 1 else 0
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_i_opencl(n, x, nu, expo, verbose = verbose),
    fallback_expr = function() rep(base::besselI(x, nu, expon.scaled = expon.scaled), n),
    fallback = fallback, verbose = verbose, fn_name = "besselI_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselJ_opencl <- function(n, x, nu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(nu, "nu")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_j_opencl(n, x, nu, verbose = verbose),
    fallback_expr = function() rep(base::besselJ(x, nu), n),
    fallback = fallback, verbose = verbose, fn_name = "besselJ_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselK_opencl <- function(n, x, nu, expon.scaled = FALSE, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(nu, "nu")
  .validate_flag(expon.scaled, "expon.scaled")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  expo <- if (isTRUE(expon.scaled)) 1 else 0
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_k_opencl(n, x, nu, expo, verbose = verbose),
    fallback_expr = function() rep(base::besselK(x, nu, expon.scaled = expon.scaled), n),
    fallback = fallback, verbose = verbose, fn_name = "besselK_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselY_opencl <- function(n, x, nu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(nu, "nu")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_y_opencl(n, x, nu, verbose = verbose),
    fallback_expr = function() rep(base::besselY(x, nu), n),
    fallback = fallback, verbose = verbose, fn_name = "besselY_opencl"
  )
}
