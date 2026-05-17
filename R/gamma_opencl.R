#' The Gamma Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the gamma distribution. These mirror the base \code{stats} gamma family
#' while adding OpenCL dispatch and optional CPU fallback behavior.
#'
#' @param x Numeric scalar quantile for \code{dgamma_opencl}.
#' @param q Numeric vector of quantiles for \code{pgamma_opencl} (same role as \code{stats::pgamma}).
#' @param p Numeric scalar probability in \code{[0, 1]} for \code{qgamma_opencl}.
#' @param n Number of observations. Non-negative integer scalar (\code{dgamma_opencl}, \code{qgamma_opencl}, \code{rgamma_opencl}).
#' @param shape Shape parameter (must be > 0).
#' @param scale Scale parameter (must be > 0). For \code{pgamma_opencl}, combined with \code{rate}
#'   like \code{stats::pgamma}.
#' @param rate Optional rate for \code{pgamma_opencl}; see \code{\link[stats]{pgamma}}.
#' @param lower.tail,log.p As in \code{stats::pgamma} for \code{pgamma_opencl} (recycled).
#' @param opencl_parallel Single logical passed through for future parallel dispatch (\code{pgamma_opencl}; unused).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU \code{stats} function
#'   when OpenCL is unavailable or the OpenCL call fails.
#' @param verbose Logical; print informational fallback messages.
#'
#' @details
#' \code{\link{pgamma_opencl}} follows \code{\link[stats]{pgamma}} argument names and
#' \code{rate}/\code{scale} handling (including the error when both are supplied
#' inconsistently). Recycling of \code{q}, \code{shape}, and \code{scale} follows
#' \code{stats::pgamma}. Vector \code{lower.tail} and \code{log.p} are recycled
#' row-wise with those arguments (like \code{\link{pnorm_opencl}}); a single-vector
#' \code{stats::pgamma()} call does not apply tail flags element-wise.
#' There is no leading \code{n} argument for \code{pgamma_opencl}.
#' On the GPU path each recycled row runs \code{pgamma_kernel}
#' once with \code{n_out = 1}. Missing or non-finite values after recycling, or non-positive
#' \code{shape}/\code{scale}, use row-wise \code{stats::pgamma}.
#'
#' @return Numeric vector result from the corresponding gamma-family operation.
#' @example inst/examples/Ex_gamma_opencl.R
#' @rdname gamma_opencl
#' @export
dgamma_opencl <- function(n, x, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dgamma_opencl(n, x, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::dgamma(x, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "dgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
pgamma_opencl <- function(
    q,
    shape,
    rate = 1,
    scale = 1/rate,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(shape)) {
    stop("`shape` must be numeric.")
  }

  if (!missing(scale) && !missing(rate)) {
    m <- max(length(scale), length(rate))
    sc <- rep_len(scale, m)
    rt <- rep_len(rate, m)
    if (any(abs(sc * rt - 1) > 1e-15, na.rm = TRUE)) {
      stop("specify 'rate' or 'scale' but not both", call. = FALSE)
    }
    scale <- sc
  } else if (!missing(rate)) {
    scale <- 1 / rate
  }

  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
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
    length(shape),
    length(scale),
    length(lower.tail),
    length(log.p)
  )
  len <- max(lens)
  if (len == 0L) {
    return(numeric(0))
  }
  if (len > 0L && any(lens == 0L)) {
    stop(
      "arguments of length zero cannot be recycled when the output length is positive (see ?pgamma).",
      call. = FALSE
    )
  }
  if (len > .Machine$integer.max) {
    stop(
      "`q` / `shape` / `scale` / `lower.tail` / `log.p` are too long for the OpenCL interface.",
      call. = FALSE
    )
  }

  qv <- rep_len(q, len)
  sh <- rep_len(shape, len)
  sc <- rep_len(scale, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pgamma(
        qv[i],
        shape = sh[i],
        scale = sc[i],
        lower.tail = ltv[i],
        log.p = lpv[i]
      )
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(sh) | !is.finite(sc))) {
    return(fallback_full())
  }

  if (any(sh <= 0 | sc <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  lt_int <- as.integer(ltv)
  lp_int <- as.integer(lpv)

  qv <- as.double(qv)
  sh <- as.double(sh)
  sc <- as.double(sc)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pgamma_opencl(qv, sh, sc, lt_int, lp_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
qgamma_opencl <- function(n, p, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qgamma_opencl(n, p, shape, scale, verbose = verbose),
    fallback_expr = function() rep(stats::qgamma(p, shape = shape, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "qgamma_opencl"
  )
}

#' @rdname gamma_opencl
#' @export
rgamma_opencl <- function(n, shape, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(shape, "shape", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rgamma_opencl(n, shape, scale, verbose = verbose),
    fallback_expr = function() stats::rgamma(n, shape = shape, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rgamma_opencl"
  )
}
