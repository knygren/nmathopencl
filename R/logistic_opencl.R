#' The Logistic Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the logistic distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{plogis_opencl}; recycled like \code{stats::plogis}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param location Location parameter.
#' @param scale Scale parameter (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::plogis} for \code{plogis_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{plogis_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_logistic_opencl.R
#' @rdname logistic_opencl
#' @export
dlogis_opencl <- function(n, x, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dlogis_opencl(n, x, location, scale, verbose = verbose),
    fallback_expr = function() rep(stats::dlogis(x, location = location, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "dlogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
plogis_opencl <- function(
    q,
    location = 0,
    scale = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(location)) {
    stop("`location` must be numeric.")
  }
  if (!is.numeric(scale)) {
    stop("`scale` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(location), length(scale), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?plogis")

  qv <- rep_len(q, len)
  lv <- rep_len(location, len)
  sv <- rep_len(scale, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::plogis(qv[i], location = lv[i], scale = sv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(lv) | !is.finite(sv))) {
    return(fallback_full())
  }

  if (any(sv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .plogis_opencl(
        as.double(qv),
        as.double(lv),
        as.double(sv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "plogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
qlogis_opencl <- function(n, p, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qlogis_opencl(n, p, location, scale, verbose = verbose),
    fallback_expr = function() rep(stats::qlogis(p, location = location, scale = scale), n),
    fallback = fallback, verbose = verbose, fn_name = "qlogis_opencl"
  )
}

#' @rdname logistic_opencl
#' @export
rlogis_opencl <- function(n, location = 0, scale = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(location, "location")
  .validate_scalar_num(scale, "scale", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rlogis_opencl(n, location, scale, verbose = verbose),
    fallback_expr = function() stats::rlogis(n, location = location, scale = scale),
    fallback = fallback, verbose = verbose, fn_name = "rlogis_opencl"
  )
}
