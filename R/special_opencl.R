#' Special Functions (OpenCL)
#'
#' OpenCL-backed wrappers for selected special functions from R Mathlib.
#'
#' @param x Numeric vector (and additional vectors where listed); arguments are
#'   recycled to a common length like the corresponding base functions.
#' @param deriv Derivative order for \code{psigamma_opencl} (recycled with \code{x}).
#' @param a,b Parameters for \code{beta_opencl} / \code{lbeta_opencl} (recycled together).
#' @param n,k Arguments for \code{choose_opencl} / \code{lchoose_opencl}, like
#'   \code{base::choose(n, k)} (recycled together).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). Defaults to \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of recycled common length.
#' @example inst/examples/Ex_special_opencl.R
#' @rdname special_opencl
#' @export
gammafn_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .gammafn_opencl(xv, verbose = verbose),
    fallback_expr = function() base::gamma(xv),
    fallback = fallback, verbose = verbose, fn_name = "gammafn_opencl"
  )
}

#' @rdname special_opencl
#' @export
lgammafn_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .lgammafn_opencl(xv, verbose = verbose),
    fallback_expr = function() base::lgamma(xv),
    fallback = fallback, verbose = verbose, fn_name = "lgammafn_opencl"
  )
}

#' @rdname special_opencl
#' @export
digamma_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .digamma_opencl(xv, verbose = verbose),
    fallback_expr = function() base::digamma(xv),
    fallback = fallback, verbose = verbose, fn_name = "digamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
trigamma_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .trigamma_opencl(xv, verbose = verbose),
    fallback_expr = function() base::trigamma(xv),
    fallback = fallback, verbose = verbose, fn_name = "trigamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
tetragamma_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .tetragamma_opencl(xv, verbose = verbose),
    fallback_expr = function() base::psigamma(xv, deriv = 2L),
    fallback = fallback, verbose = verbose, fn_name = "tetragamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
pentagamma_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .pentagamma_opencl(xv, verbose = verbose),
    fallback_expr = function() base::psigamma(xv, deriv = 3L),
    fallback = fallback, verbose = verbose, fn_name = "pentagamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
psigamma_opencl <- function(x, deriv, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(deriv)) stop("`deriv` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(deriv) == 0L) return(numeric(0))
  lens <- c(length(x), length(deriv))
  len <- .p_stage1_recycle_len(lens, "?psigamma")
  xv <- rep_len(as.double(x), len)
  dv <- rep_len(as.double(deriv), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .psigamma_opencl(xv, dv, verbose = verbose),
    fallback_expr = function() base::psigamma(xv, deriv = dv),
    fallback = fallback, verbose = verbose, fn_name = "psigamma_opencl"
  )
}

#' @rdname special_opencl
#' @export
beta_opencl <- function(a, b, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(a)) stop("`a` must be numeric.")
  if (!is.numeric(b)) stop("`b` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(a) == 0L && length(b) == 0L) return(numeric(0))
  lens <- c(length(a), length(b))
  len <- .p_stage1_recycle_len(lens, "?beta")
  av <- rep_len(as.double(a), len)
  bv <- rep_len(as.double(b), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .beta_opencl(av, bv, verbose = verbose),
    fallback_expr = function() base::beta(av, bv),
    fallback = fallback, verbose = verbose, fn_name = "beta_opencl"
  )
}

#' @rdname special_opencl
#' @export
lbeta_opencl <- function(a, b, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(a)) stop("`a` must be numeric.")
  if (!is.numeric(b)) stop("`b` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(a) == 0L && length(b) == 0L) return(numeric(0))
  lens <- c(length(a), length(b))
  len <- .p_stage1_recycle_len(lens, "?lbeta")
  av <- rep_len(as.double(a), len)
  bv <- rep_len(as.double(b), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .lbeta_opencl(av, bv, verbose = verbose),
    fallback_expr = function() base::lbeta(av, bv),
    fallback = fallback, verbose = verbose, fn_name = "lbeta_opencl"
  )
}

#' @rdname special_opencl
#' @export
choose_opencl <- function(n, k, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(n)) stop("`n` must be numeric.")
  if (!is.numeric(k)) stop("`k` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(n) == 0L && length(k) == 0L) return(numeric(0))
  lens <- c(length(n), length(k))
  len <- .p_stage1_recycle_len(lens, "?choose")
  nv <- rep_len(as.double(n), len)
  kv <- rep_len(as.double(k), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .choose_opencl(nv, kv, verbose = verbose),
    fallback_expr = function() base::choose(nv, kv),
    fallback = fallback, verbose = verbose, fn_name = "choose_opencl"
  )
}

#' @rdname special_opencl
#' @export
lchoose_opencl <- function(n, k, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(n)) stop("`n` must be numeric.")
  if (!is.numeric(k)) stop("`k` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(n) == 0L && length(k) == 0L) return(numeric(0))
  lens <- c(length(n), length(k))
  len <- .p_stage1_recycle_len(lens, "?lchoose")
  nv <- rep_len(as.double(n), len)
  kv <- rep_len(as.double(k), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .lchoose_opencl(nv, kv, verbose = verbose),
    fallback_expr = function() base::lchoose(nv, kv),
    fallback = fallback, verbose = verbose, fn_name = "lchoose_opencl"
  )
}
