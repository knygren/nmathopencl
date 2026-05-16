#' The Normal Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the normal distribution. These mirror the base \code{stats} normal family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @details
#' \code{\link{pnorm_opencl}} uses the same first five statistical arguments as
#' \code{\link[stats]{pnorm}}, in the same order: \code{q}, \code{mean}, \code{sd},
#' \code{lower.tail}, and \code{log.p}, with identical defaults (\code{mean = 0}, \code{sd = 1},
#' \code{lower.tail = TRUE}, \code{log.p = FALSE}). It adds \code{opencl_parallel},
#' \code{fallback}, and \code{verbose}. There is no leading \code{n} argument (that convention
#' applies to \code{\link{qnorm_opencl}} / \code{\link{rnorm_opencl}}).
#' Recycling for \code{pnorm_opencl} follows \code{\link[stats]{pnorm}} once those arguments are aligned.
#' On the GPU path, each
#' recycled parameter row is evaluated with the existing scalar \code{pnorm_kernel} one after
#' another (\code{len} submissions; useful before a batched kernel).
#' Combining vector \code{q}, \code{mean}, \code{sd}, \code{lower.tail}, and \code{log.p} yields
#' one OpenCL scalar evaluation per output index (full recycling to common length).
#' If \code{q} has length zero, \code{numeric(0)} is returned immediately (matching
#' \code{\link[stats]{pnorm}}). Missing or non-finite
#' values (after recycling), or any \code{sd == 0}, are evaluated with CPU
#' \code{\link[stats]{pnorm}}. Undefined zero-length recycling stops with an error; negative
#' \code{sd} stops with an error.
#'
#' @param x Numeric vector of quantiles.
#' @param q Numeric vector of quantiles for \code{pnorm_opencl} (same role as \code{stats::pnorm}).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param n Number of observations (non-negative integer scalar). Used by \code{qnorm_opencl}
#'   and \code{rnorm_opencl}; not an argument to \code{pnorm_opencl}.
#' @param mean Location parameter. Scalar for \code{dnorm_opencl} and \code{rnorm_opencl}.
#'   For \code{pnorm_opencl}, recycled like \code{stats::pnorm}.
#' @param sd Scale parameter. Scalar (\code{sd >= 0}) for \code{dnorm_opencl} and
#'   \code{rnorm_opencl}. For \code{pnorm_opencl}, recycled like \code{stats::pnorm}.
#'   The GPU path runs only when every recycled value is strictly positive (\code{sd > 0});
#'   \code{sd == 0} is evaluated with \code{stats::pnorm}.
#' @param lower.tail,log.p As in \code{stats::pnorm} (recycled). Row-wise semantics follow
#'   full recycling; for some combinations of arguments, plain \code{stats::pnorm} with vector
#'   arguments may replicate only scalar \code{lower.tail}/\code{log.p}.
#' @param opencl_parallel Single logical: \code{TRUE} forces parallel dispatch when implemented,
#'   \code{FALSE} serial, \code{NA} automatic (reserved; not yet used by \code{pnorm_opencl} GPU dispatch).
#' @param log Logical; if \code{TRUE}, return log densities.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU \code{stats} function
#'   when OpenCL is unavailable or the OpenCL call fails.
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
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(mean) || length(mean) != 1L || is.na(mean)) {
    stop("`mean` must be a single non-missing numeric value.")
  }
  if (!is.numeric(sd) || length(sd) != 1L || is.na(sd) || sd < 0) {
    stop("`sd` must be a single non-missing numeric value >= 0.")
  }
  if (!is.logical(log) || length(log) != 1L || is.na(log)) {
    stop("`log` must be TRUE or FALSE.")
  }
  if (!is.logical(fallback) || length(fallback) != 1L || is.na(fallback)) {
    stop("`fallback` must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE.")
  }

  if (!has_opencl()) {
    if (fallback) {
      if (verbose) message("[dnorm_opencl] OpenCL unavailable; using stats::dnorm fallback.")
      return(stats::dnorm(x, mean = mean, sd = sd, log = log))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(.dnorm_opencl(x, mean = mean, sd = sd, log = log, verbose = verbose), error = function(e) e)
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[dnorm_opencl] OpenCL call failed; using stats::dnorm fallback.")
        message(out$message)
      }
      return(stats::dnorm(x, mean = mean, sd = sd, log = log))
    }
    stop(out$message, call. = FALSE)
  }

  out
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
    fallback = TRUE,
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
qnorm_opencl <- function(n, p, mean = 0, sd = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(mean, "mean")
  .validate_scalar_num(sd, "sd", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnorm_opencl(n, p, mean, sd, verbose = verbose),
    fallback_expr = function() rep(stats::qnorm(p, mean = mean, sd = sd), n),
    fallback = fallback, verbose = verbose, fn_name = "qnorm_opencl"
  )
}

#' @rdname normal_opencl
#' @export
rnorm_opencl <- function(
    n,
    mean = 0,
    sd = 1,
    fallback = TRUE,
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

  if (!has_opencl()) {
    if (fallback) {
      if (verbose) message("[rnorm_opencl] OpenCL unavailable; using stats::rnorm fallback.")
      return(stats::rnorm(n, mean = mean, sd = sd))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(.rnorm_opencl(n, mean = mean, sd = sd, verbose = verbose), error = function(e) e)
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[rnorm_opencl] OpenCL call failed; using stats::rnorm fallback.")
        message(out$message)
      }
      return(stats::rnorm(n, mean = mean, sd = sd))
    }
    stop(out$message, call. = FALSE)
  }

  out
}
