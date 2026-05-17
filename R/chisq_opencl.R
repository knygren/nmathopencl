#' The Chi-squared Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the chi-squared distribution, including non-central paths via \code{ncp}.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rchisq_opencl};
#'   \code{dchisq_opencl} takes vector \code{x} first (like \code{stats::dchisq}).
#' @param x Numeric vector of quantiles for \code{dchisq_opencl}.
#' @param p Numeric vector of probabilities for \code{qchisq_opencl} (like \code{stats::qchisq}).
#' @param df Degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0).
#' @param q Numeric vector of quantiles for \code{pchisq_opencl}; recycled like \code{stats::pchisq}.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_chisq_opencl.R
#' @rdname chisq_opencl
#' @export
dchisq_opencl <- function(
    x,
    df,
    ncp = 0,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(ncp)) {
    stop("`ncp` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(df), length(ncp), length(log))
  len <- .p_stage1_recycle_len(lens, "?dchisq")

  xv <- rep_len(as.double(x), len)
  dfv <- rep_len(as.double(df), len)
  ncv <- rep_len(as.double(ncp), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dchisq(x, df = df, ncp = ncp, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(dfv) | !is.finite(ncv))) {
    return(fallback_full())
  }

  if (any(xv < 0)) {
    stop("`x` must be non-negative (after recycling).", call. = FALSE)
  }

  if (any(dfv <= 0 | ncv < 0)) {
    stop("`df` must be positive and `ncp` non-negative (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dchisq_opencl(xv, dfv, ncv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dchisq_opencl"
  )
}

#' @rdname chisq_opencl
#' @export
pchisq_opencl <- function(
    q,
    df,
    ncp = 0,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(ncp)) {
    stop("`ncp` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(df), length(ncp), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pchisq")

  qv <- rep_len(q, len)
  dfv <- rep_len(df, len)
  ncv <- rep_len(ncp, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pchisq(qv[i], df = dfv[i], ncp = ncv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(dfv) | !is.finite(ncv))) {
    return(fallback_full())
  }

  if (any(dfv <= 0 | ncv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pchisq_opencl(
        as.double(qv),
        as.double(dfv),
        as.double(ncv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pchisq_opencl"
  )
}

#' @rdname chisq_opencl
#' @export
qchisq_opencl <- function(
    p,
    df,
    ncp = 0,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(ncp)) {
    stop("`ncp` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(df), length(ncp), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qchisq")

  pv <- rep_len(as.double(p), len)
  dfv <- rep_len(as.double(df), len)
  ncv <- rep_len(as.double(ncp), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qchisq(pv[i], df = dfv[i], ncp = ncv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(dfv) | !is.finite(ncv))) {
    return(fallback_full())
  }

  if (any(dfv <= 0 | ncv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qchisq_opencl(pv, dfv, ncv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qchisq_opencl"
  )
}

#' @rdname chisq_opencl
#' @export
rchisq_opencl <- function(n, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .rchisq_opencl(n, df, verbose = verbose)
      } else {
        .rnchisq_opencl(n, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() stats::rchisq(n, df = df, ncp = ncp),
    fallback = fallback, verbose = verbose, fn_name = "rchisq_opencl"
  )
}

