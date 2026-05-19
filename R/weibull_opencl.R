#' The Weibull Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Weibull distribution.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rweibull_opencl}.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q \code{p*}-wrapper quantiles (\code{stats::pweibull} semantics).
#' @param p Numeric vector of probabilities for \code{qweibull_opencl} (like \code{stats::qweibull}).
#' @param shape Shape parameter (must be > 0).
#' @param scale Scale parameter (must be > 0).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL. Defaults \code{TRUE} only for \code{qweibull_opencl} temporarily (\file{inst/OPENCL_PGAMMA_UTILS_KERNEL_FALLBACK_TEMP.md}); density/survival/rand stay \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @return Numeric vector result from the corresponding Weibull-family operation.
#' @example inst/examples/Ex_weibull_opencl.R
#' @rdname weibull_opencl
#' @export
dweibull_opencl <- function(
    x,
    shape,
    scale = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(shape)) {
    stop("`shape` must be numeric.")
  }
  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(shape), length(scale), length(log))
  len <- .p_stage1_recycle_len(lens, "?dweibull")

  xv <- rep_len(as.double(x), len)
  shv <- rep_len(as.double(shape), len)
  scv <- rep_len(as.double(scale), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dweibull(x, shape = shape, scale = scale, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(shv) | !is.finite(scv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | shv <= 0 | scv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dweibull_opencl(xv, shv, scv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
pweibull_opencl <- function(
    q,
    shape,
    scale = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(shape)) {
    stop("`shape` must be numeric.")
  }
  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(shape), length(scale), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pweibull")

  qv <- rep_len(q, len)
  sh <- rep_len(shape, len)
  sc <- rep_len(scale, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pweibull(qv[i], shape = sh[i], scale = sc[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(sh) | !is.finite(sc))) {
    return(fallback_full())
  }

  if (any(sh <= 0 | sc <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pweibull_opencl(
        as.double(qv),
        as.double(sh),
        as.double(sc),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
qweibull_opencl <- function(
    p,
    shape,
    scale = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(shape)) {
    stop("`shape` must be numeric.")
  }
  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(shape), length(scale), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qweibull")

  pv <- rep_len(as.double(p), len)
  sh <- rep_len(as.double(shape), len)
  sc <- rep_len(as.double(scale), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qweibull(pv[i], shape = sh[i], scale = sc[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(sh) | !is.finite(sc))) {
    return(fallback_full())
  }

  if (any(sh <= 0 | sc <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qweibull_opencl(pv, sh, sc, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qweibull_opencl"
  )
}

#' @rdname weibull_opencl
#' @export
rweibull_opencl <- function(n, shape, scale = 1, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rweibull_opencl(n, shape, scale, verbose = verbose),
    fallback_expr = function() stats::rweibull(n, shape = shape, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rweibull_opencl"
  )
}
