#' OpenCL-backed RNG Core linkage checks
#'
#' Linkage wrappers for core RNG primitives used by translated Mathlib paths.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param dn Positive upper bound used by \code{r_unif_index_opencl}.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). Defaults to \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_rng_core_opencl.R
#' @rdname rng_core_opencl
#' @export
norm_rand_opencl <- function(n, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .norm_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rnorm(n),
    fallback = fallback, verbose = verbose, fn_name = "norm_rand_opencl"
  )
}

#' @rdname rng_core_opencl
#' @export
unif_rand_opencl <- function(n, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .unif_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::runif(n),
    fallback = fallback, verbose = verbose, fn_name = "unif_rand_opencl"
  )
}

#' @rdname rng_core_opencl
#' @export
r_unif_index_opencl <- function(n, dn, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(dn, "dn", lower = 0, upper = Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_unif_index_opencl(n, dn, verbose = verbose),
    fallback_expr = function() floor(stats::runif(n, min = 0, max = dn)),
    fallback = fallback, verbose = verbose, fn_name = "r_unif_index_opencl"
  )
}

#' @rdname rng_core_opencl
#' @export
exp_rand_opencl <- function(n, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .exp_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rexp(n),
    fallback = fallback, verbose = verbose, fn_name = "exp_rand_opencl"
  )
}
