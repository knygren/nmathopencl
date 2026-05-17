#' The Binomial Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the binomial distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric vector of quantiles for \code{pbinom_opencl}; recycled like \code{stats::pbinom}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param size Number of trials (must be >= 0).
#' @param prob Probability of success in \code{[0, 1]}.
#' @param qprob Complementary probability. If \code{NULL}, uses \code{1 - prob}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::pbinom} for \code{pbinom_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{pbinom_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_binomial_opencl.R
#' @rdname binomial_opencl
#' @export
dbinom_raw_opencl <- function(n, x, size, prob, qprob = NULL, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  if (is.null(qprob)) {
    qprob <- 1 - prob
  }
  .validate_scalar_num(qprob, "qprob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dbinom_raw_opencl(n, x, size, prob, qprob, verbose = verbose),
    fallback_expr = function() rep(stats::dbinom(x, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dbinom_raw_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
dbinom_opencl <- function(n, x, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dbinom_opencl(n, x, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::dbinom(x, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
pbinom_opencl <- function(
    q,
    size,
    prob,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(size)) {
    stop("`size` must be numeric.")
  }
  if (!is.numeric(prob)) {
    stop("`prob` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(size), length(prob), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pbinom")

  qv <- rep_len(q, len)
  sv <- rep_len(size, len)
  pv <- rep_len(prob, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pbinom(qv[i], size = sv[i], prob = pv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(sv) | !is.finite(pv))) {
    return(fallback_full())
  }

  if (any(sv < 0 | pv < 0 | pv > 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pbinom_opencl(
        as.double(qv),
        as.double(sv),
        as.double(pv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
qbinom_opencl <- function(n, p, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qbinom_opencl(n, p, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::qbinom(p, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "qbinom_opencl"
  )
}

#' @rdname binomial_opencl
#' @export
rbinom_opencl <- function(n, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rbinom_opencl(n, size, prob, verbose = verbose),
    fallback_expr = function() stats::rbinom(n, size = size, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rbinom_opencl"
  )
}
