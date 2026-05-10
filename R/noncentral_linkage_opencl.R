#' OpenCL-backed pchisq linkage check
#' @export
pchisq_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnchisq_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pchisq(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pchisq_opencl"
  )
}

#' OpenCL-backed qchisq linkage check
#' @export
qchisq_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnchisq_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qchisq(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qchisq_opencl"
  )
}

#' OpenCL-backed pf linkage check
#' @export
pf_opencl <- function(n, x, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnf_opencl(n, x, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pf(x, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pf_opencl"
  )
}

#' OpenCL-backed qf linkage check
#' @export
qf_opencl <- function(n, p, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnf_opencl(n, p, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qf(p, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qf_opencl"
  )
}

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
pnchisq_opencl <- function(...) pchisq_opencl(...)
qnchisq_opencl <- function(...) qchisq_opencl(...)
pnf_opencl <- function(...) pf_opencl(...)
qnf_opencl <- function(...) qf_opencl(...)
pnbeta_opencl <- function(...) pbeta_opencl(...)
qnbeta_opencl <- function(...) qbeta_opencl(...)
pnt_opencl <- function(...) pt_opencl(...)
qnt_opencl <- function(...) qt_opencl(...)
