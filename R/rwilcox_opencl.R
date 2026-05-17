#' The Wilcoxon Rank Sum Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Wilcoxon rank sum distribution.
#'
#' @param n Draw-count scalar (\code{r*} path only).
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q \code{p*}-wrapper quantiles (\code{stats::pwilcox} semantics).
#' @param p \code{q*}-wrapper probabilities (\code{stats::qwilcox} semantics).
#' @param m Number of observations in one sample (must be > 0).
#' @param nn Number of observations in the other sample (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @section Known OpenCL limitations:
#' Wilcoxon kernels can still hit runtime-shim gaps depending on device and
#' driver stack (for example unresolved runtime symbols in some builds).
#' Prefer \code{fallback = TRUE} for production paths.
#'
#' @return Numeric vector result from the corresponding Wilcoxon-family operation.
#' @example inst/examples/Ex_wilcox_opencl.R
#' @rdname wilcox_opencl
#' @export
dwilcox_opencl <- function(
    x,
    m,
    nn,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(nn)) {
    stop("`nn` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(m), length(nn), length(log))
  len <- .p_stage1_recycle_len(lens, "?dwilcox")

  xv <- rep_len(as.double(x), len)
  mv <- rep_len(as.double(m), len)
  n2v <- rep_len(as.double(nn), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dwilcox(x, m = m, n = nn, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(mv) | !is.finite(n2v))) {
    return(fallback_full())
  }

  if (any(xv < 0 | mv <= 0 | n2v <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dwilcox_opencl(xv, mv, n2v, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
pwilcox_opencl <- function(
    q,
    m,
    nn,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(nn)) {
    stop("`nn` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(m), length(nn), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pwilcox")

  qv <- rep_len(q, len)
  mv <- rep_len(m, len)
  nv <- rep_len(nn, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pwilcox(qv[i], m = mv[i], n = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(mv <= 0 | nv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pwilcox_opencl(
        as.double(qv),
        as.double(mv),
        as.double(nv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
qwilcox_opencl <- function(
    p,
    m,
    nn,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(nn)) {
    stop("`nn` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(m), length(nn), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qwilcox")

  pv <- rep_len(as.double(p), len)
  mv <- rep_len(as.double(m), len)
  nv <- rep_len(as.double(nn), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qwilcox(pv[i], m = mv[i], n = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(mv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(mv <= 0 | nv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qwilcox_opencl(pv, mv, nv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
rwilcox_opencl <- function(n, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rwilcox_opencl(n, m = m, nn = nn, verbose = verbose),
    fallback_expr = function() stats::rwilcox(n, m = m, n = nn),
    fallback = fallback, verbose = verbose, fn_name = "rwilcox_opencl"
  )
}
