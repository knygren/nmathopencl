#' OpenCL-backed norm_rand linkage check
#' @export
norm_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .norm_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rnorm(n),
    fallback = fallback, verbose = verbose, fn_name = "norm_rand_opencl"
  )
}

#' OpenCL-backed unif_rand linkage check
#' @export
unif_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .unif_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::runif(n),
    fallback = fallback, verbose = verbose, fn_name = "unif_rand_opencl"
  )
}

#' OpenCL-backed R_unif_index linkage check
#' @export
r_unif_index_opencl <- function(n, dn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(dn, "dn", lower = 0, upper = Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_unif_index_opencl(n, dn, verbose = verbose),
    fallback_expr = function() floor(stats::runif(n, min = 0, max = dn)),
    fallback = fallback, verbose = verbose, fn_name = "r_unif_index_opencl"
  )
}

#' OpenCL-backed exp_rand linkage check
#' @export
exp_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .exp_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rexp(n),
    fallback = fallback, verbose = verbose, fn_name = "exp_rand_opencl"
  )
}
