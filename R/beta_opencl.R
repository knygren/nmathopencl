#' The Beta Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the beta distribution. These mirror the base \code{stats} beta family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rbeta_opencl}.
#' @param x \code{(0,1)} quantiles for central/non-central densities on this page.
#' @param p Numeric vector of probabilities for \code{qbeta_opencl} (like \code{stats::qbeta}).
#' @param shape1 First shape parameter (must be > 0).
#' @param shape2 Second shape parameter (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0). Used by
#'   \code{dnbeta_opencl()}, \code{pbeta_opencl()}, and \code{qbeta_opencl()}.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails.
#' Ignored when the runtime reports no OpenCL. \strong{Density} wrappers (\code{dbeta},\code{dnbeta}) default \code{FALSE} so OpenCL errors surface (\file{inst/OPENCL_PGAMMA_UTILS_KERNEL_FALLBACK_TEMP.md}); \strong{distribution and quantile} (\code{pbeta},\code{qbeta}) default \code{TRUE} temporarily until the \code{pgamma_utils}-related device build issues clear. Pass \code{fallback = TRUE} on densities only if CPU recovery is acceptable. \code{rbeta_opencl} retains \code{FALSE}. See also \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param q Numeric vector of quantiles for \code{pbeta_opencl}; recycled like \code{stats::pbeta}.
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} density flags for density wrappers (\code{stats} semantics).
#'
#' @section Known OpenCL limitations:
#' \describe{
#'   \item{Non-central tails}{\code{qbeta_opencl} with \code{ncp > 0} may stress devices.}
#'   \item{Build quirks}{\code{Rf_lbeta} linkage breaks on GPUs; skip GPU demos.\cr
#' Tracker: \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}}
#' }
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_beta_opencl.R
#' @rdname beta_opencl
#' @export
dbeta_opencl <- function(
    x,
    shape1,
    shape2,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(shape1)) {
    stop("`shape1` must be numeric.")
  }
  if (!is.numeric(shape2)) {
    stop("`shape2` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(shape1), length(shape2), length(log))
  len <- .p_stage1_recycle_len(lens, "?dbeta")

  xv <- rep_len(as.double(x), len)
  a <- rep_len(as.double(shape1), len)
  b <- rep_len(as.double(shape2), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dbeta(x, shape1 = shape1, shape2 = shape2, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(a) | !is.finite(b))) {
    return(fallback_full())
  }

  if (any(xv < 0 | xv > 1)) {
    stop("`x` must lie in [0, 1] (after recycling).", call. = FALSE)
  }

  if (any(a <= 0 | b <= 0)) {
    stop("`shape1` and `shape2` must be strictly positive (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dbeta_opencl(xv, a, b, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
dnbeta_opencl <- function(
    x,
    shape1,
    shape2,
    ncp,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(shape1)) {
    stop("`shape1` must be numeric.")
  }
  if (!is.numeric(shape2)) {
    stop("`shape2` must be numeric.")
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

  lens <- c(length(x), length(shape1), length(shape2), length(ncp), length(log))
  len <- .p_stage1_recycle_len(lens, "?dbeta")

  xv <- rep_len(as.double(x), len)
  a <- rep_len(as.double(shape1), len)
  b <- rep_len(as.double(shape2), len)
  nv <- rep_len(as.double(ncp), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dbeta(x, shape1 = shape1, shape2 = shape2, ncp = ncp, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(a) | !is.finite(b) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | xv > 1)) {
    stop("`x` must lie in [0, 1] (after recycling).", call. = FALSE)
  }

  if (any(a <= 0 | b <= 0 | nv < 0)) {
    stop("`shape1`/`shape2` must be positive and `ncp` non-negative (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dnbeta_opencl(xv, a, b, nv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dnbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
pbeta_opencl <- function(
    q,
    shape1,
    shape2,
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
  if (!is.numeric(shape1)) {
    stop("`shape1` must be numeric.")
  }
  if (!is.numeric(shape2)) {
    stop("`shape2` must be numeric.")
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

  lens <- c(
    length(q),
    length(shape1),
    length(shape2),
    length(ncp),
    length(lower.tail),
    length(log.p)
  )
  len <- .p_stage1_recycle_len(lens, "?pbeta")

  qv <- rep_len(q, len)
  av <- rep_len(shape1, len)
  bv <- rep_len(shape2, len)
  nv <- rep_len(ncp, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pbeta(
        qv[i],
        shape1 = av[i],
        shape2 = bv[i],
        ncp = nv[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(av) | !is.finite(bv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(av <= 0 | bv <= 0 | nv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pbeta_opencl(
        as.double(qv),
        as.double(av),
        as.double(bv),
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
    fn_name = "pbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
qbeta_opencl <- function(
    p,
    shape1,
    shape2,
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
  if (!is.numeric(shape1)) {
    stop("`shape1` must be numeric.")
  }
  if (!is.numeric(shape2)) {
    stop("`shape2` must be numeric.")
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

  lens <- c(
    length(p),
    length(shape1),
    length(shape2),
    length(ncp),
    length(lower.tail),
    length(log.p)
  )
  len <- .p_stage1_recycle_len(lens, "?qbeta")

  pv <- rep_len(as.double(p), len)
  av <- rep_len(as.double(shape1), len)
  bv <- rep_len(as.double(shape2), len)
  nv <- rep_len(as.double(ncp), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qbeta(
        pv[i],
        shape1 = av[i],
        shape2 = bv[i],
        ncp = nv[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(av) | !is.finite(bv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(av <= 0 | bv <= 0 | nv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qbeta_opencl(pv, av, bv, nv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qbeta_opencl"
  )
}

#' @rdname beta_opencl
#' @export
rbeta_opencl <- function(n, shape1, shape2, fallback = FALSE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape1, "shape1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(shape2, "shape2", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rbeta_opencl(n, shape1, shape2, verbose = verbose),
    fallback_expr = function() stats::rbeta(n, shape1 = shape1, shape2 = shape2),
    fallback = fallback, verbose = verbose, fn_name = "rbeta_opencl"
  )
}

