#' OpenCL-backed R_pow linkage check
#' @export
r_pow_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() (x + seq_len(n) * 1e-3)^y,
    fallback = fallback, verbose = verbose, fn_name = "r_pow_opencl"
  )
}

#' OpenCL-backed R_pow_di linkage check
#' @export
r_pow_di_opencl <- function(n, x, n_exp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  if (!is.numeric(n_exp) || length(n_exp) != 1L || is.na(n_exp) || n_exp != as.integer(n_exp)) {
    stop("`n_exp` must be a single integer value.")
  }
  n_exp <- as.integer(n_exp)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_di_opencl(n, x, n_exp, verbose = verbose),
    fallback_expr = function() rep(x^n_exp, n),
    fallback = fallback, verbose = verbose, fn_name = "r_pow_di_opencl"
  )
}
