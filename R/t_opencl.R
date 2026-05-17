#' The Student t Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the Student t distribution.
#'
#' @param n Number of observations. Non-negative integer scalar (\code{dt_opencl}, \code{qt_opencl}, \code{rt_opencl}).
#' @param x Numeric scalar quantile (\code{dt_opencl}).
#' @param q Numeric vector of quantiles (\code{pt_opencl}); recycled like \code{stats::pt}.
#' @param p Numeric scalar probability in \code{[0, 1]} (\code{qt_opencl}).
#' @param df Degrees of freedom (must be > 0).
#' @param ncp Non-centrality parameter.
#' @param lower.tail,log.p As in \code{stats::pt} for \code{pt_opencl} (vector inputs recycled).
#' @param opencl_parallel Reserved for future parallel dispatch (\code{pt_opencl}; unused).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return For \code{dt_opencl}, \code{qt_opencl}, \code{rt_opencl}: numeric vector of length \code{n}.
#'   For \code{pt_opencl}: numeric vector of recycled length (see \code{stats::pt}).
#' @example inst/examples/Ex_t_opencl.R
#' @rdname t_opencl
#' @export
dt_opencl <- function(n, x, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x")
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .dt_opencl(n, x, df, verbose = verbose)
      } else {
        .dnt_opencl(n, x, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::dt(x, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "dt_opencl"
  )
}

#' @rdname t_opencl
#' @export
pt_opencl <- function(
    q,
    df,
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
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
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

  lens <- c(length(q), length(df), length(ncp), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?pt")

  qv <- rep_len(q, len)
  dfv <- rep_len(df, len)
  nv <- rep_len(ncp, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::pt(qv[i], df = dfv[i], ncp = nv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(dfv) | !is.finite(nv))) {
    return(fallback_full())
  }

  if (any(dfv <= 0)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .pt_opencl(
        as.double(qv),
        as.double(dfv),
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
    fn_name = "pt_opencl"
  )
}

#' @rdname t_opencl
#' @export
qt_opencl <- function(n, p, df, ncp = 0, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(ncp, "ncp")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() {
      if (ncp == 0) {
        .qt_opencl(n, p, df, verbose = verbose)
      } else {
        .qnt_opencl(n, p, df, ncp, verbose = verbose)
      }
    },
    fallback_expr = function() rep(stats::qt(p, df = df, ncp = ncp), n),
    fallback = fallback, verbose = verbose, fn_name = "qt_opencl"
  )
}

#' @rdname t_opencl
#' @export
rt_opencl <- function(n, df, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rt_opencl(n, df, verbose = verbose),
    fallback_expr = function() stats::rt(n, df = df),
    fallback = fallback, verbose = verbose, fn_name = "rt_opencl"
  )
}

