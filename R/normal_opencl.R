#' The Normal Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the normal distribution. These mirror the base \code{stats} normal family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @details
#' \code{pnorm_opencl} matches \code{\link[stats]{pnorm}} on the first five statistical
#' arguments (\code{q}, \code{mean}, \code{sd}, \code{lower.tail}, \code{log.p}) and the
#' usual defaults. It also accepts \code{opencl_parallel}, \code{fallback}, and
#' \code{verbose}. Only \code{\link{rnorm_opencl}} uses a leading \code{n}. \cr
#' Recycling follows \code{\link[stats]{pnorm}} once arguments are aligned. On the GPU path,
#' each recycled row calls the scalar \code{pnorm_kernel} once (\code{len} submissions). \cr
#' Vector \code{q}, \code{mean}, \code{sd}, \code{lower.tail}, and \code{log.p} yield one
#' OpenCL evaluation per output index. \cr
#' Length-zero \code{q} returns \code{numeric(0)} as in \code{\link[stats]{pnorm}}. \cr
#' Missing or non-finite values (after recycling), or any \code{sd == 0}, use CPU
#' \code{\link[stats]{pnorm}}. Zero-length recycling errors and negative \code{sd} still error.
#'
#' @param x Numeric vector of quantiles.
#' @param q Numeric vector of quantiles for \code{pnorm_opencl} (same role as \code{stats::pnorm}).
#' @param p Numeric vector of probabilities for \code{qnorm_opencl} (like \code{stats::qnorm}).
#' @param n Number of observations (non-negative integer scalar). Used only by \code{rnorm_opencl};
#'   not an argument to \code{pnorm_opencl} / \code{qnorm_opencl}.
#' @param mean Location parameter (\code{rnorm}: scalar).
#'   For \code{pnorm_opencl} and \code{qnorm_opencl}, recycled like the corresponding \code{stats}
#'   function.
#' @param sd Scale parameter (\code{rnorm}: scalar, \code{sd >= 0}).
#'   For \code{pnorm_opencl} and \code{qnorm_opencl}, recycled like the corresponding \code{stats}
#'   function. The GPU path runs only when every recycled value is strictly positive (\code{sd > 0});
#'   \code{sd == 0} is evaluated with \code{stats::pnorm}.
#' @param lower.tail,log.p Recycling for \code{pnorm_opencl}; see Details for contrasts with
#'   some vector \code{stats::pnorm} calls.
#' @param opencl_parallel Dispatch hint \code{(TRUE,FALSE,NA)} for \emph{p}/\emph{q}
#'   wrappers on this page; parallel kernels reserved.
#' @param log \code{log} flag for \code{dnorm_opencl} (\code{stats} semantics).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). Defaults to \code{FALSE}.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector result from the corresponding normal-family operation.
#' @example inst/examples/Ex_normal_opencl.R
#' @rdname normal_opencl
#' @export
dnorm_opencl <- function(
    x,
    mean = 0,
    sd = 1,
    log = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(mean)) {
    stop("`mean` must be numeric.")
  }
  if (!is.numeric(sd)) {
    stop("`sd` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(mean), length(sd), length(log))
  len <- .p_stage1_recycle_len(lens, "?dnorm")

  xv <- rep_len(as.double(x), len)
  mv <- rep_len(as.double(mean), len)
  sv <- rep_len(as.double(sd), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dnorm(x, mean = mean, sd = sd, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(mv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv < 0)) {
    stop("`sd` must be non-negative (after recycling to common length).", call. = FALSE)
  }

  if (any(sv == 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dnorm_opencl(xv, mv, sv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dnorm_opencl"
  )
}

#' @rdname normal_opencl
#' @export
pnorm_opencl <- function(
    q,
    mean = 0,
    sd = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(mean)) {
    stop("`mean` must be numeric.")
  }
  if (!is.numeric(sd)) {
    stop("`sd` must be numeric.")
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
    length(mean),
    length(sd),
    length(lower.tail),
    length(log.p)
  )
  len <- max(lens)
  if (len == 0L) {
    return(numeric(0))
  }
  if (len > 0L && any(lens == 0L)) {
    stop(
      "arguments of length zero cannot be recycled when the output length is positive (see ?pnorm).",
      call. = FALSE
    )
  }
  if (len > .Machine$integer.max) {
    stop("`q` / `mean` / `sd` / `lower.tail` / `log.p` are too long for the OpenCL interface.", call. = FALSE)
  }

  qv <- rep_len(q, len)
  mv <- rep_len(mean, len)
  sv <- rep_len(sd, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    stats::pnorm(q, mean = mean, sd = sd, lower.tail = lower.tail, log.p = log.p)
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv < 0)) {
    stop("`sd` must be non-negative (after recycling to common length).", call. = FALSE)
  }

  if (any(sv == 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  # GPU path (stage 1): one scalar pnorm_kernel launch per recycled row — matches stats recycling.
  qv <- as.double(qv)
  mv <- as.double(mv)
  sv <- as.double(sv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pnorm_opencl(qv, mv, sv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pnorm_opencl"
  )
}

#' @rdname normal_opencl
#' @export
qnorm_opencl <- function(
    p,
    mean = 0,
    sd = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(p)) {
    stop("`p` must be numeric.")
  }
  if (!is.numeric(mean)) {
    stop("`mean` must be numeric.")
  }
  if (!is.numeric(sd)) {
    stop("`sd` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(p) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(p), length(mean), length(sd), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?qnorm")

  pv <- rep_len(as.double(p), len)
  mv <- rep_len(as.double(mean), len)
  sv <- rep_len(as.double(sd), len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::qnorm(pv[i], mean = mv[i], sd = sv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(pv) | !is.finite(mv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv < 0)) {
    stop("`sd` must be non-negative (after recycling to common length).", call. = FALSE)
  }

  if (any(sv == 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .qnorm_opencl(pv, mv, sv, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "qnorm_opencl"
  )
}

#' @rdname normal_opencl
#' @export
rnorm_opencl <- function(
    n,
    mean = 0,
    sd = 1,
    fallback = FALSE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(mean) || length(mean) != 1L || is.na(mean)) {
    stop("`mean` must be a single non-missing numeric value.")
  }
  if (!is.numeric(sd) || length(sd) != 1L || is.na(sd) || sd < 0) {
    stop("`sd` must be a single non-missing numeric value >= 0.")
  }
  if (!is.logical(fallback) || length(fallback) != 1L || is.na(fallback)) {
    stop("`fallback` must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE.")
  }

  n <- as.integer(n)

  .opencl_try_or_fallback(
    opencl_expr = function() .rnorm_opencl(n, mean = mean, sd = sd, verbose = verbose),
    fallback_expr = function() stats::rnorm(n, mean = mean, sd = sd),
    fallback = fallback,
    verbose = verbose,
    fn_name = "rnorm_opencl"
  )
}
