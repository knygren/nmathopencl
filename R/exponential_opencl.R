#' The Exponential Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the exponential distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{pexp_opencl}; recycled like \code{stats::pexp}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param rate Rate parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::pexp} for \code{pexp_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{pexp_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#' @param log Logical; if \code{TRUE}, return log-density for \code{dexp_opencl} (like \code{\link[stats]{dexp}}).
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_exponential_opencl.R
#' @rdname exponential_opencl
#' @export
dexp_opencl <- function(
    x,
    rate = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(rate)) {
    stop("`rate` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(rate), length(log))
  len <- .p_stage1_recycle_len(lens, "?dexp")

  xv <- rep_len(as.double(x), len)
  rv <- rep_len(as.double(rate), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dexp(x, rate = rate, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(rv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | rv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dexp_opencl(xv, rv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
pexp_opencl <- function(
    q,
    rate = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(rate)) {
    stop("`rate` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(rate), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pexp")

  qv <- rep_len(q, len)
  rv <- rep_len(rate, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pexp(qv[i], rate = rv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(rv))) {
    return(fallback_full())
  }

  if (any(rv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pexp_opencl(as.double(qv), as.double(rv), as.integer(ltv), as.integer(lpv), opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
qexp_opencl <- function(n, p, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qexp_opencl(n, p, rate, verbose = verbose),
    fallback_expr = function() rep(stats::qexp(p, rate = rate), n),
    fallback = fallback, verbose = verbose, fn_name = "qexp_opencl"
  )
}

#' @rdname exponential_opencl
#' @export
rexp_opencl <- function(n, rate = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(rate, "rate", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rexp_opencl(n, rate = rate, verbose = verbose),
    fallback_expr = function() stats::rexp(n, rate = rate),
    fallback = fallback, verbose = verbose, fn_name = "rexp_opencl"
  )
}
