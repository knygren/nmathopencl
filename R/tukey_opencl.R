#' The Studentized Range Distribution (OpenCL)
#'
#' OpenCL-backed distribution and quantile wrappers for the studentized range
#' (Tukey) distribution.
#'
#' @param q Numeric vector of quantiles for \code{ptukey_opencl}; recycled like \code{stats::ptukey}.
#' @param p Numeric vector of probabilities for \code{qtukey_opencl} (like \code{stats::qtukey}).
#' @param nmeans Number of means in each range (must be >= 2).
#' @param df Degrees of freedom (must be > 0).
#' @param nranges Number of groups whose maxima/minima define the range (must be >= 1).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL. Defaults \code{TRUE} temporarily (\file{inst/OPENCL_PGAMMA_UTILS_KERNEL_FALLBACK_TEMP.md}); pass \code{FALSE} to surface failures.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#'
#' @return Numeric vector result from \code{ptukey_opencl} or \code{qtukey_opencl}.
#' @example inst/examples/Ex_tukey_opencl.R
#' @rdname tukey_opencl
#' @export
ptukey_opencl <- function(
    q,
    nmeans,
    df,
    nranges = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(nmeans)) {
    stop("`nmeans` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(nranges)) {
    stop("`nranges` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(nmeans), length(df), length(nranges), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?ptukey")

  qv <- rep_len(q, len)
  nm <- rep_len(nmeans, len)
  dfv <- rep_len(df, len)
  rv <- rep_len(nranges, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::ptukey(qv[i], nmeans = nm[i], df = dfv[i], nranges = rv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(nm) | !is.finite(dfv) | !is.finite(rv))) {
    return(fallback_full())
  }

  if (any(nm < 2 | dfv <= 0 | rv < 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .ptukey_opencl(
        as.double(qv),
        as.double(nm),
        as.double(dfv),
        as.double(rv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "ptukey_opencl"
  )
}

#' @rdname tukey_opencl
#' @export
qtukey_opencl <- function(
    p,
    nmeans,
    df,
    nranges = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(nmeans)) {
    stop("`nmeans` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(nranges)) {
    stop("`nranges` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(nmeans), length(df), length(nranges), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qtukey")

  pv <- rep_len(as.double(p), len)
  nm <- rep_len(as.double(nmeans), len)
  dfv <- rep_len(as.double(df), len)
  rv <- rep_len(as.double(nranges), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qtukey(
        pv[i],
        nmeans = nm[i],
        df = dfv[i],
        nranges = rv[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(nm) | !is.finite(dfv) | !is.finite(rv))) {
    return(fallback_full())
  }

  if (any(nm < 2 | dfv <= 0 | rv < 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qtukey_opencl(pv, nm, dfv, rv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qtukey_opencl"
  )
}
