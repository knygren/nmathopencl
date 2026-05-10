#' OpenCL-backed exponential random generation with graceful fallback
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param rate Rate for the exponential distribution (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to \code{\link[stats]{rexp}}
#'   when OpenCL is unavailable or fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector of length \code{n}.
#' @export
rexp_opencl <- function(
    n,
    rate = 1,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(rate) || length(rate) != 1L || is.na(rate) || rate <= 0) {
    stop("`rate` must be a single non-missing numeric value > 0.")
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
      if (verbose) message("[rexp_opencl] OpenCL unavailable; using stats::rexp fallback.")
      return(stats::rexp(n, rate = rate))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(
    .rexp_opencl(n, rate = rate, verbose = verbose),
    error = function(e) e
  )
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[rexp_opencl] OpenCL call failed; using stats::rexp fallback.")
        message(out$message)
      }
      return(stats::rexp(n, rate = rate))
    }
    stop(out$message, call. = FALSE)
  }

  out
}
