#' OpenCL-backed pt linkage check
#' @export
pt_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnt_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pt_opencl"
  )
}

#' OpenCL-backed qt linkage check
#' @export
qt_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnt_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qt(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qt_opencl"
  )
}

# Backward-compatible aliases (old Mathlib-style names)
pnt_opencl <- function(...) pt_opencl(...)
qnt_opencl <- function(...) qt_opencl(...)
