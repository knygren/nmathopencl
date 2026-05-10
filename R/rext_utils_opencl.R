#' OpenCL-backed R_CheckUserInterrupt linkage check
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

#' OpenCL-backed R_CheckStack linkage check
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
