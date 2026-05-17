#' The Gamma Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the gamma distribution. These mirror the base \code{stats} gamma family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param x Numeric vector of quantiles for \code{dgamma_opencl}.
#' @param q Numeric vector of quantiles for \code{pgamma_opencl} (same role as \code{stats::pgamma}).
#' @param p Numeric vector of probabilities for \code{qgamma_opencl} (like \code{stats::qgamma}).
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rgamma_opencl};
#'   \code{dgamma_opencl} takes vector \code{x} first (like \code{stats::dgamma}).
#' @param shape Shape parameter (must be > 0).
#' @param scale Scale parameter (must be > 0). For \code{pgamma_opencl}, combined with \code{rate}
#'   like \code{stats::pgamma}.
#' @param rate Optional rate for \code{pgamma_opencl}; see \code{\link[stats]{pgamma}}.
#' @param log \code{log} flag for densities (\code{stats} \emph{d}-family semantics).
#' @param lower.tail,log.p Tail/log-\emph{p} inputs (\code{stats} meanings).
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for
#'   \code{pgamma_opencl}/\code{qgamma_opencl}; parallel dispatch reserved.
#' @param fallback CPU when GPU dispatch/OpenCL lacks (\link{has_opencl}).\cr
#' Prefer fixing kernel builds over masking ---
#' \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#' @param verbose Logical; print informational fallback messages.
#'
#' @details
#' \code{\link{pgamma_opencl}} follows \code{\link[stats]{pgamma}} argument names and
#' \code{rate}/\code{scale} handling (including the error when both are supplied
#' inconsistently). Recycling of \code{q}, \code{shape}, and \code{scale} follows
#' \code{stats::pgamma}. Vector \code{lower.tail} and \code{log.p} are recycled
#' row-wise with those arguments (like \code{\link{pnorm_opencl}}); a single-vector
#' \code{stats::pgamma()} call does not apply tail flags element-wise.
#' There is no leading \code{n} argument for \code{pgamma_opencl}.
#' On the GPU path each recycled row runs \code{pgamma_kernel}
#' once with \code{n_out = 1}. Missing or non-finite values after recycling, or non-positive
#' \code{shape}/\code{scale}, use row-wise \code{stats::pgamma}.
#'
#' @section Known OpenCL limitations:
#' Compilation of \code{qgamma_kernel} can fail (\code{ptxas}: unresolved \code{stirlerr_cycle_free}).
#' Runnable examples omit GPU \code{qgamma_opencl} until resolved.
#' See \file{inst/OPENCL_KERNEL_KNOWN_FAILURES.md}.
#'
#' @return Numeric vector result from the corresponding gamma-family operation.
#' @example inst/examples/Ex_gamma_opencl.R
#' @rdname gamma_opencl
#' @export
dgamma_opencl <- function(
    x,
    shape,
    scale = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
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
  len <- .p_stage1_recycle_len(lens, "?dgamma")

  xv <- rep_len(as.double(x), len)
  shv <- rep_len(as.double(shape), len)
  scv <- rep_len(as.double(scale), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dgamma(x, shape = shape, scale = scale, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(shv) | !is.finite(scv))) {
    return(fallback_full())
  }

  if (any(shv <= 0 | scv <= 0)) {
    stop("`shape` and `scale` must be strictly positive (after recycling).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dgamma_opencl(xv, shv, scv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
pgamma_opencl <- function(
    q,
    shape,
    rate = 1,
    scale = 1/rate,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(shape)) {
    stop("`shape` must be numeric.")
  }

  if (!missing(scale) && !missing(rate)) {
    m <- max(length(scale), length(rate))
    sc <- rep_len(scale, m)
    rt <- rep_len(rate, m)
    if (any(abs(sc * rt - 1) > 1e-15, na.rm = TRUE)) {
      stop("specify 'rate' or 'scale' but not both", call. = FALSE)
    }
    scale <- sc
  } else if (!missing(rate)) {
    scale <- 1 / rate
  }

  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
  }
  if (!is.logical(lower.tail) || any(is.na(lower.tail))) {
    stop("`lower.tail` must be logical with no missing values.")
  }
  if (!is.logical(log.p) || any(is.na(log.p))) {
    stop("`log.p` must be logical with no missing values.")
  }

  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(
    length(q),
    length(shape),
    length(scale),
    length(lower.tail),
    length(log.p)
  )
  len <- max(lens)
  if (len == 0L) {
    return(numeric(0))
  }
  if (len > 0L && any(lens == 0L)) {
    stop(
      "arguments of length zero cannot be recycled when the output length is positive (see ?pgamma).",
      call. = FALSE
    )
  }
  if (len > .Machine$integer.max) {
    stop(
      "`q` / `shape` / `scale` / `lower.tail` / `log.p` are too long for the OpenCL interface.",
      call. = FALSE
    )
  }

  qv <- rep_len(q, len)
  sh <- rep_len(shape, len)
  sc <- rep_len(scale, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pgamma(
        qv[i],
        shape = sh[i],
        scale = sc[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(sh) | !is.finite(sc))) {
    return(fallback_full())
  }

  if (any(sh <= 0 | sc <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  qv <- as.double(qv)
  sh <- as.double(sh)
  sc <- as.double(sc)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pgamma_opencl(qv, sh, sc, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
qgamma_opencl <- function(
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
  len <- .p_stage1_recycle_len(lens, "?qgamma")

  pv <- rep_len(as.double(p), len)
  sh <- rep_len(as.double(shape), len)
  sc <- rep_len(as.double(scale), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qgamma(pv[i], shape = sh[i], scale = sc[i], lower.tail = ltv[i], log.p = lpv[i])
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
      .qgamma_opencl(pv, sh, sc, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
rgamma_opencl <- function(n, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rgamma_opencl(n, shape, scale, verbose = verbose),
    fallback_expr = function() stats::rgamma(n, shape = shape, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rgamma_opencl"
  )
}
