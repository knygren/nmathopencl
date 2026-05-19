#' The Logistic Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the logistic distribution.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rlogis_opencl}.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{plogis_opencl}; recycled like \code{stats::plogis}.
#' @param p Numeric vector of probabilities for \code{qlogis_opencl} (like \code{stats::qlogis}).
#' @param location Location parameter.
#' @param scale Scale parameter (must be > 0).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails.
#' Ignored when the runtime reports no OpenCL. See \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint (\code{TRUE}, \code{FALSE}, \code{NA}) for \code{plogis_opencl}
#'   and \code{qlogis_opencl}; parallel kernels reserved.
#' @param log \code{log} density switch for \code{dlogis_opencl} (\code{stats} semantics).
#'
#' @section Known OpenCL limitations:
#' Some platforms fail to link \code{qlogis_kernel} (\code{ptxas} unresolved \code{Rf_qlogis}).
#' Runnable examples omit GPU \code{qlogis_opencl} until resolved.
#' See \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#'
#' @return Numeric vector result from the corresponding logistic-family operation.
#' @example inst/examples/Ex_logistic_opencl.R
#' @rdname logistic_opencl
#' @export
dlogis_opencl <- function(
    x,
    location = 0,
    scale = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(location)) {
    stop("`location` must be numeric.")
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

  lens <- c(length(x), length(location), length(scale), length(log))
  len <- .p_stage1_recycle_len(lens, "?dlogis")

  xv <- rep_len(as.double(x), len)
  locv <- rep_len(as.double(location), len)
  scv <- rep_len(as.double(scale), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dlogis(x, location = location, scale = scale, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(locv) | !is.finite(scv))) {
    return(fallback_full())
  }

  if (any(scv <= 0)) {
    stop("`scale` must be strictly positive (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dlogis_opencl(xv, locv, scv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dlogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
plogis_opencl <- function(
    q,
    location = 0,
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
  if (!is.numeric(location)) {
    stop("`location` must be numeric.")
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

  lens <- c(length(q), length(location), length(scale), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?plogis")

  qv <- rep_len(q, len)
  lv <- rep_len(location, len)
  sv <- rep_len(scale, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::plogis(qv[i], location = lv[i], scale = sv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(lv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .plogis_opencl(
        as.double(qv),
        as.double(lv),
        as.double(sv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "plogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
qlogis_opencl <- function(
    p,
    location = 0,
    scale = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(location)) {
    stop("`location` must be numeric.")
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

  lens <- c(length(p), length(location), length(scale), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qlogis")

  pv <- rep_len(as.double(p), len)
  lv <- rep_len(as.double(location), len)
  sv <- rep_len(as.double(scale), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qlogis(pv[i], location = lv[i], scale = sv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(lv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qlogis_opencl(pv, lv, sv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qlogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
rlogis_opencl <- function(n, location = 0, scale = 1, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rlogis_opencl(n, location, scale, verbose = verbose),
    fallback_expr = function() stats::rlogis(n, location = location, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rlogis_opencl"
  )
}
