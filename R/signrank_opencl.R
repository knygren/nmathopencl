#' The Wilcoxon Signed Rank Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Wilcoxon signed rank distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric vector of quantiles for \code{psignrank_opencl}; recycled like \code{stats::psignrank}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param nsize Number of observations used by signed-rank routines (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::psignrank} for \code{psignrank_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{psignrank_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#' @param log Logical; if \code{TRUE}, return log-density for \code{dsignrank_opencl} (like \code{\link[stats]{dsignrank}}).
#'
#' @section Known OpenCL limitations:
#' Signed-rank kernels can fail to build on some GPU toolchains due to unresolved
#' runtime allocation symbols (for example \code{R_chk_calloc}). Keep
#' \code{fallback = TRUE} for production use until device-safe allocator shims are
#' complete.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_signrank_opencl.R
#' @rdname signrank_opencl
#' @export
dsignrank_opencl <- function(
    x,
    nsize,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(nsize)) {
    stop("`nsize` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(nsize), length(log))
  len <- .p_stage1_recycle_len(lens, "?dsignrank")

  xv <- rep_len(as.double(x), len)
  nv <- rep_len(as.double(nsize), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dsignrank(x, n = nsize, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | nv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dsignrank_opencl(xv, nv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dsignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
psignrank_opencl <- function(
    q,
    nsize,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(nsize)) {
    stop("`nsize` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(nsize), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?psignrank")

  qv <- rep_len(q, len)
  nv <- rep_len(nsize, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::psignrank(qv[i], n = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(nv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .psignrank_opencl(as.double(qv), as.double(nv), as.integer(ltv), as.integer(lpv), opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "psignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
qsignrank_opencl <- function(n, p, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qsignrank_opencl(n, p, nsize, verbose = verbose),
    fallback_expr = function() rep(stats::qsignrank(p, n = nsize), n),
    fallback = fallback, verbose = verbose, fn_name = "qsignrank_opencl"
  )
}

#' @rdname signrank_opencl
#' @export
rsignrank_opencl <- function(n, nsize, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(nsize, "nsize", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rsignrank_opencl(n, nsize, verbose = verbose),
    fallback_expr = function() stats::rsignrank(n, n = nsize),
    fallback = fallback, verbose = verbose, fn_name = "rsignrank_opencl"
  )
}
