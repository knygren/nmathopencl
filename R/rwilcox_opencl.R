#' OpenCL-backed Wilcoxon random generation with graceful fallback
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param m Number of observations in one sample (must be > 0).
#' @param nn Number of observations in the other sample (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to \code{\link[stats]{rwilcox}}
#'   when OpenCL is unavailable or fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @return Numeric vector of length \code{n}.
#' @export
rwilcox_opencl <- function(
    n,
    m,
    nn,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  if (!is.numeric(m) || length(m) != 1L || is.na(m) || m <= 0) {
    stop("`m` must be a single non-missing numeric value > 0.")
  }
  if (!is.numeric(nn) || length(nn) != 1L || is.na(nn) || nn <= 0) {
    stop("`nn` must be a single non-missing numeric value > 0.")
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
      if (verbose) message("[rwilcox_opencl] OpenCL unavailable; using stats::rwilcox fallback.")
      return(stats::rwilcox(n, m, nn))
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(
    .rwilcox_opencl(n, m = m, nn = nn, verbose = verbose),
    error = function(e) e
  )
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message("[rwilcox_opencl] OpenCL call failed; using stats::rwilcox fallback.")
        message(out$message)
      }
      return(stats::rwilcox(n, m, nn))
    }
    stop(out$message, call. = FALSE)
  }

  out
}
