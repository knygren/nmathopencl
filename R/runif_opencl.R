#' OpenCL-backed uniform random generation with graceful fallback
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param min Lower limit of the distribution.
#' @param max Upper limit of the distribution.
#' @param fallback Logical; if \code{TRUE}, fall back to \code{\link[stats]{runif}}
#'   when OpenCL is unavailable or fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector of length \code{n}.
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
  if (max < min) {
    stop("`max` must be >= `min`.")
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
      if (verbose) message("[runif_opencl] OpenCL unavailable; using stats::runif fallback.")
      return(stats::runif(n, min = min, max = max))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(
    .runif_opencl(n, min = min, max = max, verbose = verbose),
    error = function(e) e
  )
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
