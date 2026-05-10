#' OpenCL-backed pbeta linkage check
#' @export
pbeta_opencl <- function(n, x, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnbeta_opencl(n, x, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pnbeta(x, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pbeta_opencl"
  )
}

#' OpenCL-backed qbeta linkage check
#' @export
qbeta_opencl <- function(n, p, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbeta_opencl(n, p, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qbeta(p, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qbeta_opencl"
  )
}

# Backward-compatible aliases (old Mathlib-style names)
pnbeta_opencl <- function(...) pbeta_opencl(...)
qnbeta_opencl <- function(...) qbeta_opencl(...)
