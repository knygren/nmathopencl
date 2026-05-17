#' The Poisson Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Poisson distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric vector of quantiles for \code{ppois_opencl}; recycled like \code{stats::ppois}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param lambda Mean/rate parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::ppois} for \code{ppois_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{ppois_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#' @param log Logical; if \code{TRUE}, return log-density for \code{dpois_raw_opencl} / \code{dpois_opencl} (like \code{\link[stats]{dpois}}).
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_poisson_opencl.R
#' @rdname poisson_opencl
#' @export
dpois_raw_opencl <- function(
    x,
    lambda,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(lambda)) {
    stop("`lambda` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(lambda), length(log))
  len <- .p_stage1_recycle_len(lens, "?dpois")

  xv <- rep_len(as.double(x), len)
  lv <- rep_len(as.double(lambda), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dpois(x, lambda = lambda, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(lv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | lv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dpois_raw_opencl(xv, lv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dpois_raw_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
dpois_opencl <- function(
    x,
    lambda,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(lambda)) {
    stop("`lambda` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(lambda), length(log))
  len <- .p_stage1_recycle_len(lens, "?dpois")

  xv <- rep_len(as.double(x), len)
  lv <- rep_len(as.double(lambda), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dpois(x, lambda = lambda, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(lv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | lv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dpois_opencl(xv, lv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dpois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
ppois_opencl <- function(
    q,
    lambda,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(lambda)) {
    stop("`lambda` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(lambda), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?ppois")

  qv <- rep_len(q, len)
  lv <- rep_len(lambda, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::ppois(qv[i], lambda = lv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(lv))) {
    return(fallback_full())
  }

  if (any(lv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .ppois_opencl(as.double(qv), as.double(lv), as.integer(ltv), as.integer(lpv), opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "ppois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
qpois_opencl <- function(n, p, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qpois_opencl(n, p, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::qpois(p, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "qpois_opencl"
  )
}

#' @rdname poisson_opencl
#' @export
rpois_opencl <- function(n, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rpois_opencl(n, lambda, verbose = verbose),
    fallback_expr = function() stats::rpois(n, lambda = lambda),
    fallback = fallback, verbose = verbose, fn_name = "rpois_opencl"
  )
}
