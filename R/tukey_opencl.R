#' The Studentized Range Distribution (OpenCL)
#'
#' OpenCL-backed distribution and quantile wrappers for the studentized range
#' (Tukey) distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param q Numeric vector of quantiles for \code{ptukey_opencl}; recycled like \code{stats::ptukey}.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param nmeans Number of means in each range (must be >= 2).
#' @param df Degrees of freedom (must be > 0).
#' @param nranges Number of groups whose maxima/minima define the range (must be >= 1).
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#' @param lower.tail,log.p As in \code{stats::ptukey} for \code{ptukey_opencl} (vector inputs recycled).
#' @param opencl_parallel OpenCL dispatch hint for \code{ptukey_opencl} (\code{TRUE}, \code{FALSE}, or \code{NA}); reserved for future parallel kernels.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_tukey_opencl.R
#' @rdname tukey_opencl
#' @export
ptukey_opencl <- function(
    q,
    nmeans,
    df,
    nranges = 1,
    lower.tail = TRUE,
    log.p = FALSE,
    opencl_parallel = NA,
    fallback = TRUE,
    verbose = FALSE
) {
  if (!is.numeric(q)) {
    stop("`q` must be numeric.")
  }
  if (!is.numeric(nmeans)) {
    stop("`nmeans` must be numeric.")
  }
  if (!is.numeric(df)) {
    stop("`df` must be numeric.")
  }
  if (!is.numeric(nranges)) {
    stop("`nranges` must be numeric.")
  }
  .validate_p_stage1_tails(lower.tail, log.p)
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")

  if (length(q) == 0L) {
    return(numeric(0))
  }

  lens <- c(length(q), length(nmeans), length(df), length(nranges), length(lower.tail), length(log.p))
  len <- .p_stage1_recycle_len(lens, "?ptukey")

  qv <- rep_len(q, len)
  nm <- rep_len(nmeans, len)
  dfv <- rep_len(df, len)
  rv <- rep_len(nranges, len)
  ltv <- rep_len(lower.tail, len)
  lpv <- rep_len(log.p, len)

  fallback_full <- function() {
    vapply(seq_len(len), function(i) {
      stats::ptukey(qv[i], nmeans = nm[i], df = dfv[i], nranges = rv[i], lower.tail = ltv[i], log.p = lpv[i])
    }, numeric(1L))
  }

  if (any(!is.finite(qv) | !is.finite(nm) | !is.finite(dfv) | !is.finite(rv))) {
    return(fallback_full())
  }

  if (any(nm < 2 | dfv <= 0 | rv < 1)) {
    return(fallback_full())
  }

  opc <- .encode_opencl_parallel(opencl_parallel)

  .opencl_try_or_fallback(
    opencl_expr = function() {
      .ptukey_opencl(
        as.double(qv),
        as.double(nm),
        as.double(dfv),
        as.double(rv),
        as.integer(ltv),
        as.integer(lpv),
        opc,
        verbose
      )
    },
    fallback_expr = fallback_full,
    fallback = fallback,
    verbose = verbose,
    fn_name = "ptukey_opencl"
  )
}

#' @rdname tukey_opencl
#' @export
qtukey_opencl <- function(n, p, nmeans, df, nranges = 1, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(nmeans, "nmeans", 2, Inf)
  .validate_scalar_num(df, "df", 0, Inf, open_lower = TRUE)
  .validate_scalar_num(nranges, "nranges", 1, Inf)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qtukey_opencl(n, p, nmeans, df, nranges, verbose = verbose),
    fallback_expr = function() rep(stats::qtukey(p, nmeans = nmeans, df = df, nranges = nranges), n),
    fallback = fallback, verbose = verbose, fn_name = "qtukey_opencl"
  )
}
