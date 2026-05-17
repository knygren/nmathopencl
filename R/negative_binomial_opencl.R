#' The Negative Binomial Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the negative binomial distribution, with variants parameterized by
#' \code{prob} and by \code{mu}.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile (must be >= 0).
#' @param q Numeric vector of quantiles for \code{pnbinom_opencl} / \code{pnbinom_mu_opencl}; recycled like \code{stats::pnbinom}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param size Dispersion/size parameter (must be >= 0).
#' @param prob Probability of success in \code{[0, 1]}.
#' @param mu Mean parameter (must be >= 0).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::pnbinom} for \code{pnbinom_opencl} / \code{pnbinom_mu_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{pnbinom_opencl} / \code{pnbinom_mu_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#' @param log Logical; if \code{TRUE}, return log-density for \code{dnbinom_opencl} / \code{dnbinom_mu_opencl}
#'   (like \code{\link[stats]{dnbinom}}).
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_negative_binomial_opencl.R
#' @rdname negative_binomial_opencl
#' @export
dnbinom_opencl <- function(
    x,
    size,
    prob,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(size)) {
    stop("`size` must be numeric.")
  }
  if (!is.numeric(prob)) {
    stop("`prob` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(size), length(prob), length(log))
  len <- .p_stage1_recycle_len(lens, "?dnbinom")

  xv <- rep_len(as.double(x), len)
  sv <- rep_len(as.double(size), len)
  pv <- rep_len(as.double(prob), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dnbinom(x, size = size, prob = prob, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(sv) | !is.finite(pv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | sv < 0 | pv < 0 | pv > 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dnbinom_opencl(xv, sv, pv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
pnbinom_opencl <- function(
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
  len <- .p_stage1_recycle_len(lens, "?pnbinom")

  qv <- rep_len(q, len)
  sv <- rep_len(size, len)
  pv <- rep_len(prob, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pnbinom(qv[i], size = sv[i], prob = pv[i], lower.tail = ltv[i], log.p = lpv[i])
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
      .pnbinom_opencl(
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
    fn_name = "pnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
qnbinom_opencl <- function(n, p, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbinom_opencl(n, p, size, prob, verbose = verbose),
    fallback_expr = function() rep(stats::qnbinom(p, size = size, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "qnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
rnbinom_opencl <- function(n, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rnbinom_opencl(n, size, prob, verbose = verbose),
    fallback_expr = function() stats::rnbinom(n, size = size, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rnbinom_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
dnbinom_mu_opencl <- function(
    x,
    size,
    mu,
    log = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.")
  }
  if (!is.numeric(size)) {
    stop("`size` must be numeric.")
  }
  if (!is.numeric(mu)) {
    stop("`mu` must be numeric.")
  }
  .validate_d_stage1_log(log)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(x) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(x), length(size), length(mu), length(log))
  len <- .p_stage1_recycle_len(lens, "?dnbinom")

  xv <- rep_len(as.double(x), len)
  sv <- rep_len(as.double(size), len)
  mv <- rep_len(as.double(mu), len)
  logv <- rep_len(log, len)

  fallback_full <- function() {
    stats::dnbinom(x, size = size, mu = mu, log = log)
  }

  if (any(!is.finite(xv) | !is.finite(sv) | !is.finite(mv))) {
    return(fallback_full())
  }

  if (any(xv < 0 | sv < 0 | mv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)
  log_int <- as.integer(logv)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .dnbinom_mu_opencl(xv, sv, mv, log_int, opc, verbose)
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "dnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
pnbinom_mu_opencl <- function(
    q,
    size,
    mu,
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
  if (!is.numeric(mu)) {
    stop("`mu` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(size), length(mu), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pnbinom")

  qv <- rep_len(q, len)
  sv <- rep_len(size, len)
  mv <- rep_len(mu, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pnbinom(qv[i], size = sv[i], mu = mv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(sv) | !is.finite(mv))) {
    return(fallback_full())
  }

  if (any(sv < 0 | mv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pnbinom_mu_opencl(
        as.double(qv),
        as.double(sv),
        as.double(mv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "pnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
qnbinom_mu_opencl <- function(n, p, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbinom_mu_opencl(n, p, size, mu, verbose = verbose),
    fallback_expr = function() rep(stats::qnbinom(p, size = size, mu = mu), n),
    fallback = fallback, verbose = verbose, fn_name = "qnbinom_mu_opencl"
  )
}

#' @rdname negative_binomial_opencl
#' @export
rnbinom_mu_opencl <- function(n, size, mu, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(size, "size", 0, Inf)
  .validate_scalar_num(mu, "mu", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rnbinom_mu_opencl(n, size, mu, verbose = verbose),
    fallback_expr = function() stats::rnbinom(n, size = size, mu = mu),
    fallback = fallback, verbose = verbose, fn_name = "rnbinom_mu_opencl"
  )
}
