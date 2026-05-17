#' The Uniform Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the uniform distribution. These mirror the base \code{stats} uniform
#' family while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param q Numeric vector of quantiles (\code{punif_opencl}); same role as \code{stats::punif}.
#' @param x Numeric scalar quantile for \code{dunif_opencl}.
#' @param lower.tail,log.p As in \code{stats::punif} for \code{punif_opencl} (recycled).
#' @param opencl_parallel Reserved for future parallel dispatch (\code{punif_opencl}; unused).
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param n Number of observations. Non-negative integer scalar (\code{dunif_opencl}, \code{qunif_opencl}, \code{runif_opencl}); not used by \code{punif_opencl}.
#' @param min Lower limit of the distribution.
#' @param max Upper limit of the distribution.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU \code{stats} function
#'   when OpenCL is unavailable or the OpenCL call fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector result from the corresponding uniform-family operation.
#' @example inst/examples/Ex_uniform_opencl.R
#' @rdname uniform_opencl
#' @export
dunif_opencl <- function(n, x, min = 0, max = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(min, "min")
  .validate_scalar_num(max, "max")
  if (max < min) stop("`max` must be >= `min`.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dunif_opencl(n, x, min, max, verbose = verbose),
    fallback_expr = function() rep(stats::dunif(x, min = min, max = max), n),
    fallback = fallback, verbose = verbose, fn_name = "dunif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
punif_opencl <- function(
    q,
    min = 0,
    max = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(min)) {
    stop("`min` must be numeric.")
  }
  if (!is.numeric(max)) {
    stop("`max` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(min), length(max), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?punif")

  qv <- rep_len(q, len)
  minv <- rep_len(min, len)
  maxv <- rep_len(max, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::punif(qv[i], min = minv[i], max = maxv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(minv) | !is.finite(maxv))) {
    return(fallback_full())
  }
  if (any(maxv < minv)) {
    stop("`max` must be >= `min` (after recycling to common length).", call. = FALSE)
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .punif_opencl(
        as.double(qv),
        as.double(minv),
        as.double(maxv),
        lt_int,
        lp_int,
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "punif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
qunif_opencl <- function(n, p, min = 0, max = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(min, "min")
  .validate_scalar_num(max, "max")
  if (max < min) stop("`max` must be >= `min`.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qunif_opencl(n, p, min, max, verbose = verbose),
    fallback_expr = function() rep(stats::qunif(p, min = min, max = max), n),
    fallback = fallback, verbose = verbose, fn_name = "qunif_opencl"
  )
}

#' @rdname uniform_opencl
#' @export
runif_opencl <- function(
    n,
    min = 0,
    max = 1,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(min) || length(min) != 1L || is.na(min)) {
    stop("`min` must be a single non-missing numeric value.")
  }
  if (!is.numeric(max) || length(max) != 1L || is.na(max)) {
    stop("`max` must be a single non-missing numeric value.")
  }
  if (max < min) stop("`max` must be >= `min`.")
  if (!is.logical(fallback) || length(fallback) != 1L || is.na(fallback)) {
    stop("`fallback` must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE.")
  }

  n <- as.integer(n)

  if (!has_opencl()) {
    if (fallback) {
      if (verbose) message("[runif_opencl] OpenCL unavailable; using stats::runif fallback.")
      return(stats::runif(n, min = min, max = max))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(.runif_opencl(n, min = min, max = max, verbose = verbose), error = function(e) e)
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[runif_opencl] OpenCL call failed; using stats::runif fallback.")
        message(out$message)
      }
      return(stats::runif(n, min = min, max = max))
    }
    stop(out$message, call. = FALSE)
  }

  out
}
