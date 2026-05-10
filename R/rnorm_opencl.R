#' OpenCL-backed normal random generation with graceful fallback
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param mean Mean for the normal distribution.
#' @param sd Standard deviation (must be non-negative).
#' @param fallback Logical; if \code{TRUE}, fall back to \code{\link[stats]{rnorm}}
#'   when OpenCL is unavailable or fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector of length \code{n}.
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

  out <- tryCatch(
    .rnorm_opencl(n, mean = mean, sd = sd, verbose = verbose),
    error = function(e) e
  )
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
