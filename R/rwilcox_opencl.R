#' The Wilcoxon Rank Sum Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Wilcoxon rank sum distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric vector of quantiles for \code{pwilcox_opencl}; recycled like \code{stats::pwilcox}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param m Number of observations in one sample (must be > 0).
#' @param nn Number of observations in the other sample (must be > 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::pwilcox} for \code{pwilcox_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{pwilcox_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#'
#' @section Known OpenCL limitations:
#' Wilcoxon kernels can still hit runtime-shim gaps depending on device and
#' driver stack (for example unresolved runtime symbols in some builds).
#' Prefer \code{fallback = TRUE} for production paths.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_wilcox_opencl.R
#' @rdname wilcox_opencl
#' @export
dwilcox_opencl <- function(n, x, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dwilcox_opencl(n, x, m, nn, verbose = verbose),
    fallback_expr = function() rep(stats::dwilcox(x, m = m, n = nn), n),
    fallback = fallback, verbose = verbose, fn_name = "dwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
pwilcox_opencl <- function(
    q,
    m,
    nn,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(m)) {
    stop("`m` must be numeric.")
  }
  if (!is.numeric(nn)) {
    stop("`nn` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(m), length(nn), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pwilcox")

  qv <- rep_len(q, len)
  mv <- rep_len(m, len)
  nv <- rep_len(nn, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pwilcox(qv[i], m = mv[i], n = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(mv <= 0 | nv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pwilcox_opencl(
        as.double(qv),
        as.double(mv),
        as.double(nv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
qwilcox_opencl <- function(n, p, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qwilcox_opencl(n, p, m, nn, verbose = verbose),
    fallback_expr = function() rep(stats::qwilcox(p, m = m, n = nn), n),
    fallback = fallback, verbose = verbose, fn_name = "qwilcox_opencl"
  )
}

#' @rdname wilcox_opencl
#' @export
rwilcox_opencl <- function(n, m, nn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nn, "nn", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rwilcox_opencl(n, m = m, nn = nn, verbose = verbose),
    fallback_expr = function() stats::rwilcox(n, m = m, n = nn),
    fallback = fallback, verbose = verbose, fn_name = "rwilcox_opencl"
  )
}
