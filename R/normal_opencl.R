#' The Normal Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the normal distribution. These mirror the base \code{stats} normal family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param x Numeric vector of quantiles.
#' @param q Numeric scalar quantile used by linkage wrappers.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param n Number of observations. Non-negative integer scalar.
#' @param mean Numeric scalar mean.
#' @param sd Numeric scalar standard deviation (must be positive for p/q wrappers;
#'   non-negative for \code{dnorm_opencl} and \code{rnorm_opencl}).
#' @param log Logical; if \code{TRUE}, return log densities.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU \code{stats} function
#'   when OpenCL is unavailable or the OpenCL call fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector result from the corresponding normal-family operation.
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
pnorm_opencl <- function(n, q, mean = 0, sd = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q")
  .validate_scalar_num(mean, "mean")
  .validate_scalar_num(sd, "sd", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnorm_opencl(n, q, mean, sd, verbose = verbose),
    fallback_expr = function() rep(stats::pnorm(q, mean = mean, sd = sd), n),
    fallback = fallback, verbose = verbose, fn_name = "pnorm_opencl"
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
