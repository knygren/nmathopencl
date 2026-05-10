#' OpenCL-backed R_ext runtime utility linkage checks
#'
#' Wrappers for utility hooks used by translated R_ext-dependent kernels.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @rdname rext_utils_opencl
#' @export
r_check_user_interrupt_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_check_user_interrupt_opencl(n, verbose = verbose),
    fallback_expr = function() as.numeric(seq_len(n)),
    fallback = fallback, verbose = verbose, fn_name = "r_check_user_interrupt_opencl"
  )
}

#' @rdname rext_utils_opencl
#' @export
r_check_stack_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_check_stack_opencl(n, verbose = verbose),
    fallback_expr = function() as.numeric(seq_len(n)),
    fallback = fallback, verbose = verbose, fn_name = "r_check_stack_opencl"
  )
}
