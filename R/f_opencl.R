#' The F Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the F distribution.
#'
#' @param n Number of observations. Non-negative integer scalar (\code{df_opencl}, \code{qf_opencl}, \code{rf_opencl}).
#' @param x Numeric scalar quantile (\code{df_opencl}).
#' @param q Numeric vector of quantiles (\code{pf_opencl}); recycled like \code{stats::pf}.
#' @param p Numeric scalar probability in \code{[0, 1]} (\code{qf_opencl}).
#' @param df1 Numerator degrees of freedom (must be > 0).
#' @param df2 Denominator degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter (must be >= 0). Used by
#'   \code{df_opencl()}, \code{pf_opencl()}, and \code{qf_opencl()}.
#' @param lower.tail,log.p As in \code{stats::pf} for \code{pf_opencl} (vector inputs recycled).
#' @param opencl_parallel Reserved for future parallel dispatch (\code{pf_opencl}; unused).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' \code{qf_opencl()} can fail on some GPU/driver combinations with
#' \code{CL_OUT_OF_RESOURCES}. This has been observed in both central and
#' non-central settings, with non-central paths typically more fragile.
#'
#' @return For \code{df_opencl}, \code{qf_opencl}, \code{rf_opencl}: numeric vector of length \code{n}.
#'   For \code{pf_opencl}: numeric vector of recycled length (see \code{stats::pf}).
#' @example inst/examples/Ex_f_opencl.R
#' @rdname f_opencl
#' @export
df_opencl <- function(n, x, df1, df2, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .df_opencl(n, x, df1, df2, verbose = verbose)
      } else {
        .dnf_opencl(n, x, df1, df2, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::df(x, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "df_opencl"
  )
}

#' @rdname f_opencl
#' @export
pf_opencl <- function(
    q,
    df1,
    df2,
    ncp = 0,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(df1)) {
    stop("`df1` must be numeric.")
  }
  if (!is.numeric(df2)) {
    stop("`df2` must be numeric.")
  }
  if (!is.numeric(ncp)) {
    stop("`ncp` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(df1), length(df2), length(ncp), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pf")

  qv <- rep_len(q, len)
  d1 <- rep_len(df1, len)
  d2 <- rep_len(df2, len)
  nv <- rep_len(ncp, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pf(qv[i], df1 = d1[i], df2 = d2[i], ncp = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(d1) | !is.finite(d2) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(d1 <= 0 | d2 <= 0 | nv < 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pf_opencl(
        as.double(qv),
        as.double(d1),
        as.double(d2),
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
    fn_name = "pf_opencl"
  )
}

#' @rdname f_opencl
#' @export
qf_opencl <- function(n, p, df1, df2, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp", 0, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .qf_opencl(n, p, df1, df2, verbose = verbose)
      } else {
        .qnf_opencl(n, p, df1, df2, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::qf(p, df1 = df1, df2 = df2, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qf_opencl"
  )
}

#' @rdname f_opencl
#' @export
rf_opencl <- function(n, df1, df2, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(df1, "df1", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(df2, "df2", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rf_opencl(n, df1, df2, verbose = verbose),
    fallback_expr = function() stats::rf(n, df1 = df1, df2 = df2),
    fallback = fallback, verbose = verbose, fn_name = "rf_opencl"
  )
}

