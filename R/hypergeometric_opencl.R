#' The Hypergeometric Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the hypergeometric distribution.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rhyper_opencl}.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{phyper_opencl}; recycled like \code{stats::phyper}.
#' @param p Numeric vector of probabilities for \code{qhyper_opencl} (like \code{stats::qhyper}).
#' @param m Number of white balls in the urn (must be >= 0).
#' @param n_black Number of black balls in the urn (must be >= 0).
#' @param k Number of draws (must be >= 0).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL. \code{dhyper_opencl} defaults \code{FALSE}; \code{phyper_opencl} and \code{rhyper_opencl} default \code{TRUE} temporarily (\file{inst/OPENCL_PGAMMA_UTILS_KERNEL_FALLBACK_TEMP.md}); \code{qhyper_opencl} defaults \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @return Numeric vector result from the corresponding hypergeometric-family operation.
#' @example inst/examples/Ex_hypergeometric_opencl.R
#' @rdname hypergeometric_opencl
#' @export
dhyper_opencl <- function(
    x,
    m,
    n_black,
    k,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(n_black)) {
    stop("`n_black` must be numeric.")
  }
  if (!is.numeric(k)) {
    stop("`k` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(m), length(n_black), length(k), length(log))
  len <- .p_stage1_recycle_len(lens, "?dhyper")

  xv <- rep_len(as.double(x), len)
  mv <- rep_len(as.double(m), len)
  bv <- rep_len(as.double(n_black), len)
  kv <- rep_len(as.double(k), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dhyper(x, m = m, n = n_black, k = k, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(mv) | !is.finite(bv) | !is.finite(kv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | mv < 0 | bv < 0 | kv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dhyper_opencl(xv, mv, bv, kv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
phyper_opencl <- function(
    q,
    m,
    n_black,
    k,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(n_black)) {
    stop("`n_black` must be numeric.")
  }
  if (!is.numeric(k)) {
    stop("`k` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(m), length(n_black), length(k), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?phyper")

  qv <- rep_len(q, len)
  mv <- rep_len(m, len)
  nv <- rep_len(n_black, len)
  kv <- rep_len(k, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::phyper(qv[i], m = mv[i], n = nv[i], k = kv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(nv) | !is.finite(kv))) {
    return(fallback_full())
  }

  if (any(mv < 0 | nv < 0 | kv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .phyper_opencl(
        as.double(qv),
        as.double(mv),
        as.double(nv),
        as.double(kv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "phyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
qhyper_opencl <- function(
    p,
    m,
    n_black,
    k,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(n_black)) {
    stop("`n_black` must be numeric.")
  }
  if (!is.numeric(k)) {
    stop("`k` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(m), length(n_black), length(k), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qhyper")

  pv <- rep_len(as.double(p), len)
  mv <- rep_len(as.double(m), len)
  nv <- rep_len(as.double(n_black), len)
  kv <- rep_len(as.double(k), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qhyper(
        pv[i],
        m = mv[i],
        n = nv[i],
        k = kv[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(mv) | !is.finite(nv) | !is.finite(kv))) {
    return(fallback_full())
  }

  if (any(mv < 0 | nv < 0 | kv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qhyper_opencl(pv, mv, nv, kv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
rhyper_opencl <- function(n, m, n_black, k, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rhyper_opencl(n, m, n_black, k, verbose = verbose),
    fallback_expr = function() stats::rhyper(n, m = m, n = n_black, k = k),
    fallback = fallback, verbose = verbose, fn_name = "rhyper_opencl"
  )
}
