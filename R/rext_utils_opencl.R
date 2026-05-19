#' OpenCL-backed R_ext runtime utility linkage checks
#'
#' Wrappers for utility hooks used by translated R_ext-dependent kernels.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). Defaults to \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' On some builds, \code{r_check_stack_opencl()} can fail in device compilation or
#' runtime due to missing host/runtime stack symbols. Use as linkage smoke only,
#' and keep CPU fallback enabled unless explicitly debugging OpenCL failures.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_rext_utils_opencl.R
#' @rdname rext_utils_opencl
#' @export
r_check_user_interrupt_opencl <- function(n, fallback = FALSE, verbose = FALSE) {
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
r_check_stack_opencl <- function(n, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_check_stack_opencl(n, verbose = verbose),
    fallback_expr = function() as.numeric(seq_len(n)),
    fallback = fallback, verbose = verbose, fn_name = "r_check_stack_opencl"
  )
}
