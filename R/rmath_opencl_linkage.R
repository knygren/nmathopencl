# Internal helper for scalar n validation
.validate_n_scalar <- function(n) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  as.integer(n)
}

# Internal helper for logical flags
.validate_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", name))
  }
}

# Internal helper for scalar numeric checks
.validate_scalar_num <- function(x, name, lower = -Inf, upper = Inf, open_lower = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be a single non-missing numeric value.", name))
  }
  if (open_lower) {
    if (!(x > lower && x <= upper)) {
      stop(sprintf("`%s` must be in (%s, %s].", name, lower, upper))
    }
  } else {
    if (!(x >= lower && x <= upper)) {
      stop(sprintf("`%s` must be in [%s, %s].", name, lower, upper))
    }
  }
}

# Internal helper for OpenCL call/fallback pattern
.opencl_try_or_fallback <- function(opencl_expr, fallback_expr, fallback, verbose, fn_name) {
  if (!has_opencl()) {
    if (fallback) {
      if (verbose) message(sprintf("[%s] OpenCL unavailable; using CPU fallback.", fn_name))
      return(fallback_expr())
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(opencl_expr(), error = function(e) e)
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message(sprintf("[%s] OpenCL call failed; using CPU fallback.", fn_name))
        message(out$message)
      }
      return(fallback_expr())
    }
    stop(out$message, call. = FALSE)
  }
  out
}

#' OpenCL-backed R_pow linkage check
#' @export
r_pow_opencl <- function(n, x, y, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(y, "y")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_opencl(n, x, y, verbose = verbose),
    fallback_expr = function() (x + seq_len(n) * 1e-3)^y,
    fallback = fallback, verbose = verbose, fn_name = "r_pow_opencl"
  )
}

#' OpenCL-backed R_pow_di linkage check
#' @export
r_pow_di_opencl <- function(n, x, n_exp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  if (!is.numeric(n_exp) || length(n_exp) != 1L || is.na(n_exp) || n_exp != as.integer(n_exp)) {
    stop("`n_exp` must be a single integer value.")
  }
  n_exp <- as.integer(n_exp)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_di_opencl(n, x, n_exp, verbose = verbose),
    fallback_expr = function() rep(x^n_exp, n),
    fallback = fallback, verbose = verbose, fn_name = "r_pow_di_opencl"
  )
}

#' OpenCL-backed norm_rand linkage check
#' @export
norm_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .norm_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rnorm(n),
    fallback = fallback, verbose = verbose, fn_name = "norm_rand_opencl"
  )
}

#' OpenCL-backed unif_rand linkage check
#' @export
unif_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .unif_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::runif(n),
    fallback = fallback, verbose = verbose, fn_name = "unif_rand_opencl"
  )
}

#' OpenCL-backed R_unif_index linkage check
#' @export
r_unif_index_opencl <- function(n, dn, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(dn, "dn", lower = 0, upper = Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_unif_index_opencl(n, dn, verbose = verbose),
    fallback_expr = function() floor(stats::runif(n, min = 0, max = dn)),
    fallback = fallback, verbose = verbose, fn_name = "r_unif_index_opencl"
  )
}

#' OpenCL-backed exp_rand linkage check
#' @export
exp_rand_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n); .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .exp_rand_opencl(n, verbose = verbose),
    fallback_expr = function() stats::rexp(n),
    fallback = fallback, verbose = verbose, fn_name = "exp_rand_opencl"
  )
}

#' OpenCL-backed qbinom linkage check
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

#' OpenCL-backed qpois linkage check
#' @export
qpois_opencl <- function(n, p, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qpois_opencl(n, p, lambda, verbose = verbose),
    fallback_expr = function() rep(stats::qpois(p, lambda = lambda), n),
    fallback = fallback, verbose = verbose, fn_name = "qpois_opencl"
  )
}

#' OpenCL-backed qnbinom_mu linkage check
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

#' OpenCL-backed rpois linkage check
#' @export
rpois_opencl <- function(n, lambda, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(lambda, "lambda", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rpois_opencl(n, lambda, verbose = verbose),
    fallback_expr = function() stats::rpois(n, lambda = lambda),
    fallback = fallback, verbose = verbose, fn_name = "rpois_opencl"
  )
}

#' OpenCL-backed pchisq linkage check
#' @export
pchisq_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnchisq_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pchisq(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pchisq_opencl"
  )
}

#' OpenCL-backed qchisq linkage check
#' @export
qchisq_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnchisq_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qchisq(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qchisq_opencl"
  )
}

#' OpenCL-backed pf linkage check
#' @export
pf_opencl <- function(n, x, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnf_opencl(n, x, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pf(x, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pf_opencl"
  )
}

#' OpenCL-backed qf linkage check
#' @export
qf_opencl <- function(n, p, df1, df2, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnf_opencl(n, p, df1, df2, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qf(p, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qf_opencl"
  )
}

#' OpenCL-backed pbeta linkage check
#' @export
pbeta_opencl <- function(n, x, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnbeta_opencl(n, x, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pnbeta(x, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pbeta_opencl"
  )
}

#' OpenCL-backed qbeta linkage check
#' @export
qbeta_opencl <- function(n, p, a, b, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(a, "a", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(b, "b", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnbeta_opencl(n, p, a, b, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qbeta(p, shape1 = a, shape2 = b, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qbeta_opencl"
  )
}

#' OpenCL-backed pt linkage check
#' @export
pt_opencl <- function(n, x, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pnt_opencl(n, x, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::pt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "pt_opencl"
  )
}

#' OpenCL-backed qt linkage check
#' @export
qt_opencl <- function(n, p, df, ncp, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qnt_opencl(n, p, df, ncp, verbose = verbose),
    fallback_expr = function() rep(stats::qt(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qt_opencl"
  )
}

# Backward-compatible aliases (old Mathlib-style names)
pnchisq_opencl <- function(...) pchisq_opencl(...)
qnchisq_opencl <- function(...) qchisq_opencl(...)
pnf_opencl <- function(...) pf_opencl(...)
qnf_opencl <- function(...) qf_opencl(...)
pnbeta_opencl <- function(...) pbeta_opencl(...)
qnbeta_opencl <- function(...) qbeta_opencl(...)
pnt_opencl <- function(...) pt_opencl(...)
qnt_opencl <- function(...) qt_opencl(...)

#' OpenCL-backed R_CheckUserInterrupt linkage check
#' @export
r_check_user_interrupt_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_check_user_interrupt_opencl(n, verbose = verbose),
    fallback_expr = function() as.numeric(seq_len(n)),
    fallback = fallback, verbose = verbose, fn_name = "r_check_user_interrupt_opencl"
  )
}

#' OpenCL-backed R_CheckStack linkage check
#' @export
r_check_stack_opencl <- function(n, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .r_check_stack_opencl(n, verbose = verbose),
    fallback_expr = function() as.numeric(seq_len(n)),
    fallback = fallback, verbose = verbose, fn_name = "r_check_stack_opencl"
  )
}
