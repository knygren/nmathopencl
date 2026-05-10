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
