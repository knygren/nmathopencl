#' The Lognormal Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the lognormal distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric vector of quantiles for \code{plnorm_opencl}; recycled like \code{stats::plnorm}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param meanlog Mean of the distribution on the log scale.
#' @param sdlog Standard deviation on the log scale (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::plnorm} for \code{plnorm_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{plnorm_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#' @param log Logical; if \code{TRUE}, return log-density for \code{dlnorm_opencl} (like \code{\link[stats]{dlnorm}}).
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_lnorm_opencl.R
#' @rdname lnorm_opencl
#' @export
dlnorm_opencl <- function(
    x,
    meanlog = 0,
    sdlog = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(meanlog)) {
    stop("`meanlog` must be numeric.")
  }
  if (!is.numeric(sdlog)) {
    stop("`sdlog` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(meanlog), length(sdlog), length(log))
  len <- .p_stage1_recycle_len(lens, "?dlnorm")

  xv <- rep_len(as.double(x), len)
  ml <- rep_len(as.double(meanlog), len)
  sl <- rep_len(as.double(sdlog), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dlnorm(x, meanlog = meanlog, sdlog = sdlog, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(ml) | !is.finite(sl))) {
    return(fallback_full())
  }

  if (any(xv < 0)) {
    stop("`x` must be non-negative (after recycling).", call. = FALSE)
  }

  if (any(sl <= 0)) {
    stop("`sdlog` must be strictly positive (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dlnorm_opencl(xv, ml, sl, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dlnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
plnorm_opencl <- function(
    q,
    meanlog = 0,
    sdlog = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(meanlog)) {
    stop("`meanlog` must be numeric.")
  }
  if (!is.numeric(sdlog)) {
    stop("`sdlog` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(meanlog), length(sdlog), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?plnorm")

  qv <- rep_len(q, len)
  mv <- rep_len(meanlog, len)
  sv <- rep_len(sdlog, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::plnorm(qv[i], meanlog = mv[i], sdlog = sv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .plnorm_opencl(
        as.double(qv),
        as.double(mv),
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
    fn_name = "plnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
qlnorm_opencl <- function(n, p, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qlnorm_opencl(n, p, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() rep(stats::qlnorm(p, meanlog = meanlog, sdlog = sdlog), n),
    fallback = fallback, verbose = verbose, fn_name = "qlnorm_opencl"
  )
}

#' @rdname lnorm_opencl
#' @export
rlnorm_opencl <- function(n, meanlog = 0, sdlog = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(meanlog, "meanlog")
  .validate_scalar_num(sdlog, "sdlog", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rlnorm_opencl(n, meanlog, sdlog, verbose = verbose),
    fallback_expr = function() stats::rlnorm(n, meanlog = meanlog, sdlog = sdlog),
    fallback = fallback, verbose = verbose, fn_name = "rlnorm_opencl"
  )
}
