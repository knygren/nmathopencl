#' The Hypergeometric Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the hypergeometric distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{phyper_opencl}; recycled like \code{stats::phyper}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param m Number of white balls in the urn (must be >= 0).
#' @param n_black Number of black balls in the urn (must be >= 0).
#' @param k Number of draws (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::phyper} for \code{phyper_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{phyper_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_hypergeometric_opencl.R
#' @rdname hypergeometric_opencl
#' @export
dhyper_opencl <- function(n, x, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dhyper_opencl(n, x, m, n_black, k, verbose = verbose),
    fallback_expr = function() rep(stats::dhyper(x, m = m, n = n_black, k = k), n),
    fallback = fallback, verbose = verbose, fn_name = "dhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
phyper_opencl <- function(
    q,
    m,
    n_black,
    k,
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
  if (!is.numeric(n_black)) {
    stop("`n_black` must be numeric.")
  }
  if (!is.numeric(k)) {
    stop("`k` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(m), length(n_black), length(k), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?phyper")

  qv <- rep_len(q, len)
  mv <- rep_len(m, len)
  nv <- rep_len(n_black, len)
  kv <- rep_len(k, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::phyper(qv[i], m = mv[i], n = nv[i], k = kv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(mv) | !is.finite(nv) | !is.finite(kv))) {
    return(fallback_full())
  }

  if (any(mv < 0 | nv < 0 | kv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .phyper_opencl(
        as.double(qv),
        as.double(mv),
        as.double(nv),
        as.double(kv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "phyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
qhyper_opencl <- function(n, p, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qhyper_opencl(n, p, m, n_black, k, verbose = verbose),
    fallback_expr = function() rep(stats::qhyper(p, m = m, n = n_black, k = k), n),
    fallback = fallback, verbose = verbose, fn_name = "qhyper_opencl"
  )
}

#' @rdname hypergeometric_opencl
#' @export
rhyper_opencl <- function(n, m, n_black, k, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(m, "m", 0, Inf)
  .validate_scalar_num(n_black, "n_black", 0, Inf)
  .validate_scalar_num(k, "k", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rhyper_opencl(n, m, n_black, k, verbose = verbose),
    fallback_expr = function() stats::rhyper(n, m = m, n = n_black, k = k),
    fallback = fallback, verbose = verbose, fn_name = "rhyper_opencl"
  )
}
