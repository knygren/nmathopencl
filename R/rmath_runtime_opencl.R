#' OpenCL-backed R Math runtime linkage checks
#'
#' Wrappers for low-level Mathlib runtime helpers used by translated kernels.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar input/base value.
#' @param y Numeric scalar exponent for \code{r_pow_opencl} and \code{pow1p_opencl}.
#' @param n_exp Integer exponent for \code{r_pow_di_opencl}.
#' @param logx Numeric scalar log-value for log-space combination helpers.
#' @param logy Numeric scalar log-value for log-space combination helpers.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_rmath_runtime_opencl.R
#' @rdname rmath_runtime_opencl
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

#' @rdname rmath_runtime_opencl
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

#' @rdname rmath_runtime_opencl
#' @export
log1pmx_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", -1, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .log1pmx_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(log1p(x) - x, n),
    fallback = fallback, verbose = verbose, fn_name = "log1pmx_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
log1pexp_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  cpu_val <- if (x > 0) x + log1p(exp(-x)) else log1p(exp(x))
  .opencl_try_or_fallback(
    opencl_expr = function() .log1pexp_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(cpu_val, n),
    fallback = fallback, verbose = verbose, fn_name = "log1pexp_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
log1mexp_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  cpu_val <- if (x <= log(2)) log(-expm1(-x)) else log1p(-exp(-x))
  .opencl_try_or_fallback(
    opencl_expr = function() .log1mexp_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(cpu_val, n),
    fallback = fallback, verbose = verbose, fn_name = "log1mexp_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
lgamma1p_opencl <- function(n, x, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", -1, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .lgamma1p_opencl(n, x, verbose = verbose),
    fallback_expr = function() rep(lgamma(1 + x), n),
    fallback = fallback, verbose = verbose, fn_name = "lgamma1p_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
pow1p_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", -1, Inf, open_lower = TRUE)
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pow1p_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() rep(exp(y * log1p(x)), n),
    fallback = fallback, verbose = verbose, fn_name = "pow1p_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_add_opencl <- function(n, logx, logy, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(logx, "logx")
  .validate_scalar_num(logy, "logy")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  m <- max(logx, logy)
  cpu_val <- m + log1p(exp(min(logx, logy) - m))
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_add_opencl(n, logx, logy, verbose = verbose),
    fallback_expr = function() rep(cpu_val, n),
    fallback = fallback, verbose = verbose, fn_name = "logspace_add_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_sub_opencl <- function(n, logx, logy, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(logx, "logx")
  .validate_scalar_num(logy, "logy")
  if (logy > logx) {
    stop("`logy` must be <= `logx` for logspace_sub_opencl.")
  }
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  cpu_val <- logx + log1p(-exp(logy - logx))
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_sub_opencl(n, logx, logy, verbose = verbose),
    fallback_expr = function() rep(cpu_val, n),
    fallback = fallback, verbose = verbose, fn_name = "logspace_sub_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_sum_opencl <- function(n, logx, logy, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(logx, "logx")
  .validate_scalar_num(logy, "logy")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  m <- max(logx, logy)
  cpu_val <- m + log1p(exp(min(logx, logy) - m))
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_sum_opencl(n, logx, logy, verbose = verbose),
    fallback_expr = function() rep(cpu_val, n),
    fallback = fallback, verbose = verbose, fn_name = "logspace_sum_opencl"
  )
}
