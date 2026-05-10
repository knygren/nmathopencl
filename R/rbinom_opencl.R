#' OpenCL-backed binomial random generation with graceful fallback
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param size Number of trials (must be >= 0).
#' @param prob Probability of success on each trial (must be in \code{[0, 1]}).
#' @param fallback Logical; if \code{TRUE}, fall back to \code{\link[stats]{rbinom}}
#'   when OpenCL is unavailable or fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector of length \code{n}.
#' @export
rbinom_opencl <- function(
    n,
    size,
    prob,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(size) || length(size) != 1L || is.na(size) || size < 0) {
    stop("`size` must be a single non-missing numeric value >= 0.")
  }
  if (!is.numeric(prob) || length(prob) != 1L || is.na(prob) || prob < 0 || prob > 1) {
    stop("`prob` must be a single non-missing numeric value in [0, 1].")
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
      if (verbose) message("[rbinom_opencl] OpenCL unavailable; using stats::rbinom fallback.")
      return(stats::rbinom(n, size = size, prob = prob))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(
    .rbinom_opencl(n, size = size, prob = prob, verbose = verbose),
    error = function(e) e
  )
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[rbinom_opencl] OpenCL call failed; using stats::rbinom fallback.")
        message(out$message)
      }
      return(stats::rbinom(n, size = size, prob = prob))
    }
    stop(out$message, call. = FALSE)
  }

  out
}
