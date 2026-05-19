#' The Uniform Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the uniform distribution. These mirror the base \code{stats} uniform
#' family while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param n Draw count (\code{r*}); density wrappers still lead with \code{x}.
#' @param q Numeric quantiles (\code{punif_opencl}; like \code{stats::punif}).
#' @param x Numeric scalar quantile for \code{dunif_opencl}.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param p Probabilities for \code{qunif_opencl} (\code{stats::qunif} semantics).
#' @param min Lower limit of the distribution.
#' @param max Upper limit of the distribution.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails.
#' Ignored when the runtime reports no OpenCL. See \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#' @param verbose Logical; print informational fallback messages.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @section Known OpenCL limitations:
#' Some platforms fail to link \code{qunif_kernel} (\code{ptxas} unresolved \code{Rf_qunif}).
#' Runnable examples omit GPU \code{qunif_opencl} until resolved.
#' See \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#'
#' @return Numeric vector result from the corresponding uniform-family operation.
#' @example inst/examples/Ex_uniform_opencl.R
#' @rdname uniform_opencl
#' @export
dunif_opencl <- function(
    x,
    min = 0,
    max = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(min)) {
    stop("`min` must be numeric.")
  }
  if (!is.numeric(max)) {
    stop("`max` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(min), length(max), length(log))
  len <- .p_stage1_recycle_len(lens, "?dunif")

  xv <- rep_len(as.double(x), len)
  minv <- rep_len(as.double(min), len)
  maxv <- rep_len(as.double(max), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dunif(x, min = min, max = max, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(minv) | !is.finite(maxv))) {
    return(fallback_full())
  }

  if (any(maxv < minv)) {
    stop("`max` must be >= `min` (after recycling to common length).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dunif_opencl(xv, minv, maxv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dunif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
punif_opencl <- function(
    q,
    min = 0,
    max = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(min)) {
    stop("`min` must be numeric.")
  }
  if (!is.numeric(max)) {
    stop("`max` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(min), length(max), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?punif")

  qv <- rep_len(q, len)
  minv <- rep_len(min, len)
  maxv <- rep_len(max, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::punif(qv[i], min = minv[i], max = maxv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(minv) | !is.finite(maxv))) {
    return(fallback_full())
  }
  if (any(maxv < minv)) {
    stop("`max` must be >= `min` (after recycling to common length).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .punif_opencl(
        as.double(qv),
        as.double(minv),
        as.double(maxv),
        lt_int,
        lp_int,
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "punif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
qunif_opencl <- function(
    p,
    min = 0,
    max = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(min)) {
    stop("`min` must be numeric.")
  }
  if (!is.numeric(max)) {
    stop("`max` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(min), length(max), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qunif")

  pv <- rep_len(as.double(p), len)
  minv <- rep_len(as.double(min), len)
  maxv <- rep_len(as.double(max), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qunif(pv[i], min = minv[i], max = maxv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(minv) | !is.finite(maxv))) {
    return(fallback_full())
  }

  if (any(maxv < minv)) {
    stop("`max` must be >= `min` (after recycling to common length).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qunif_opencl(pv, minv, maxv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qunif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
runif_opencl <- function(
    n,
    min = 0,
    max = 1,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(min) || length(min) != 1L || is.na(min)) {
    stop("`min` must be a single non-missing numeric value.")
  }
  if (!is.numeric(max) || length(max) != 1L || is.na(max)) {
    stop("`max` must be a single non-missing numeric value.")
  }
  if (max < min) stop("`max` must be >= `min`.")
  if (!is.logical(fallback) || length(fallback) != 1L || is.na(fallback)) {
    stop("`fallback` must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE.")
  }

  n <- as.integer(n)

  .opencl_try_or_fallback(
    opencl_expr = function() .runif_opencl(n, min = min, max = max, verbose = verbose),
    fallback_expr = function() stats::runif(n, min = min, max = max),
    fallback = fallback,
    verbose = verbose,
    fn_name = "runif_opencl"
  )
}
