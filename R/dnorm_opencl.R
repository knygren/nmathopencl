#' OpenCL-backed normal density with graceful fallback
#'
#' Computes \code{dnorm()} using the package's OpenCL path when available,
#' and gracefully falls back to \code{\link[stats]{dnorm}} otherwise.
#'
#' @param x Numeric vector of quantiles.
#' @param mean Numeric scalar mean.
#' @param sd Numeric scalar standard deviation (must be non-negative).
#' @param log Logical; if \code{TRUE}, return log densities.
#' @param fallback Logical; if \code{TRUE}, return CPU \code{stats::dnorm}
#'   when OpenCL is unavailable or the OpenCL call fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector with the same length as \code{x}.
#' @export
dnorm_opencl <- function(
    x,
    mean = 0,
    sd = 1,
    log = FALSE,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
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
      if (verbose) {
        message("[dnorm_opencl] OpenCL unavailable; using stats::dnorm fallback.")
      }
      return(stats::dnorm(x, mean = mean, sd = sd, log = log))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(
    .dnorm_opencl(x, mean = mean, sd = sd, log = log, verbose = verbose),
    error = function(e) e
  )

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
