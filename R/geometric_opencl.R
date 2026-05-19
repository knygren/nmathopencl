#' The Geometric Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the geometric distribution.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rgeom_opencl}.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{pgeom_opencl}; recycled like \code{stats::pgeom}.
#' @param p Numeric vector of probabilities for \code{qgeom_opencl} (like \code{stats::qgeom}).
#' @param prob Probability of success in \code{[0, 1]}.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL. \code{dgeom_opencl} defaults \code{FALSE}. \code{pgeom_opencl}, \code{qgeom_opencl}, and \code{rgeom_opencl} default \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#'
#' @return Numeric vector result from the corresponding geometric-family operation.
#' @example inst/examples/Ex_geometric_opencl.R
#' @rdname geometric_opencl
#' @export
dgeom_opencl <- function(
    x,
    prob,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(prob)) {
    stop("`prob` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(prob), length(log))
  len <- .p_stage1_recycle_len(lens, "?dgeom")

  xv <- rep_len(as.double(x), len)
  pv <- rep_len(as.double(prob), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dgeom(x, prob = prob, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(pv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | pv < 0 | pv > 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dgeom_opencl(xv, pv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
pgeom_opencl <- function(
    q,
    prob,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(prob)) {
    stop("`prob` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(prob), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pgeom")

  qv <- rep_len(q, len)
  pv <- rep_len(prob, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pgeom(qv[i], prob = pv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(pv))) {
    return(fallback_full())
  }

  if (any(pv < 0 | pv > 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pgeom_opencl(as.double(qv), as.double(pv), as.integer(ltv), as.integer(lpv), opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
qgeom_opencl <- function(
    p,
    prob,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(prob)) {
    stop("`prob` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(prob), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qgeom")

  pv <- rep_len(as.double(p), len)
  pb <- rep_len(as.double(prob), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qgeom(pv[i], prob = pb[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(pb))) {
    return(fallback_full())
  }

  if (any(pb < 0 | pb > 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qgeom_opencl(pv, pb, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
rgeom_opencl <- function(n, prob, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rgeom_opencl(n, prob, verbose = verbose),
    fallback_expr = function() stats::rgeom(n, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rgeom_opencl"
  )
}
