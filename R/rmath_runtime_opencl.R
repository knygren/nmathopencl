#' OpenCL-backed R Math runtime linkage checks
#'
#' Wrappers for low-level Mathlib runtime helpers used by translated kernels.
#'
#' @param x Numeric vector(s): primary input, recycled together like \code{stats}
#'   family functions. Length-zero returns \code{numeric(0)}.
#' @param y Numeric vector for \code{r_pow_opencl} and \code{pow1p_opencl}
#'   (recycled against \code{x}).
#' @param n_exp Integer vector for \code{r_pow_di_opencl}, recycled against \code{x}.
#' @param logx,logy Numeric vectors for log-space combination helpers (recycled together).
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). For \code{log1pmx_opencl}, \code{lgamma1p_opencl}, \code{pow1p_opencl}, and the \code{logspace_*} wrappers, defaults to \code{TRUE} temporarily while \code{pgamma_utils}-stitching kernels are stabilized; see \file{inst/OPENCL_PGAMMA_UTILS_KERNEL_FALLBACK_TEMP.md}.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of the recycled common length (see Details).
#' @details
#' On the GPU path, arguments are recycled to a common length \code{len} (maximum
#' argument length, R recycling rules). Each output index runs one scalar kernel launch.
#' @example inst/examples/Ex_rmath_runtime_opencl.R
#' @rdname rmath_runtime_opencl
#' @export
r_pow_opencl <- function(x, y, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?r_pow")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() (xv + seq_len(len) * 1e-3)^yv,
    fallback = fallback, verbose = verbose, fn_name = "r_pow_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
r_pow_di_opencl <- function(x, n_exp, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(n_exp)) stop("`n_exp` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(n_exp) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(x), length(n_exp))
  len <- .p_stage1_recycle_len(lens, "?r_pow")
  xv <- rep_len(as.double(x), len)
  ne <- rep_len(as.integer(n_exp), len)
  if (any(is.na(ne))) {
    stop("`n_exp` must not be NA after recycling.", call. = FALSE)
  }
  .opencl_try_or_fallback(
    opencl_expr = function() .r_pow_di_opencl(xv, ne, verbose = verbose),
    fallback_expr = function() xv^as.double(ne),
    fallback = fallback, verbose = verbose, fn_name = "r_pow_di_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
log1pmx_opencl <- function(x, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L) {
    return(numeric(0))
  }
  len <- length(x)
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .log1pmx_opencl(xv, verbose = verbose),
    fallback_expr = function() log1p(xv) - xv,
    fallback = fallback, verbose = verbose, fn_name = "log1pmx_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
log1pexp_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L) {
    return(numeric(0))
  }
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .log1pexp_opencl(xv, verbose = verbose),
    fallback_expr = function() ifelse(xv > 0, xv + log1p(exp(-xv)), log1p(exp(xv))),
    fallback = fallback, verbose = verbose, fn_name = "log1pexp_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
log1mexp_opencl <- function(x, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L) {
    return(numeric(0))
  }
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .log1mexp_opencl(xv, verbose = verbose),
    fallback_expr = function() ifelse(xv <= log(2), log(-expm1(-xv)), log1p(-exp(-xv))),
    fallback = fallback, verbose = verbose, fn_name = "log1mexp_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
lgamma1p_opencl <- function(x, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L) {
    return(numeric(0))
  }
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .lgamma1p_opencl(xv, verbose = verbose),
    fallback_expr = function() lgamma(1 + xv),
    fallback = fallback, verbose = verbose, fn_name = "lgamma1p_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
pow1p_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?pow1p")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .pow1p_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() exp(yv * log1p(xv)),
    fallback = fallback, verbose = verbose, fn_name = "pow1p_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_add_opencl <- function(logx, logy, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(logx)) stop("`logx` must be numeric.")
  if (!is.numeric(logy)) stop("`logy` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(logx) == 0L && length(logy) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(logx), length(logy))
  len <- .p_stage1_recycle_len(lens, "?logspace_add")
  logxv <- rep_len(as.double(logx), len)
  logyv <- rep_len(as.double(logy), len)
  m <- pmax(logxv, logyv)
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_add_opencl(logxv, logyv, verbose = verbose),
    fallback_expr = function() m + log1p(exp(pmin(logxv, logyv) - m)),
    fallback = fallback, verbose = verbose, fn_name = "logspace_add_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_sub_opencl <- function(logx, logy, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(logx)) stop("`logx` must be numeric.")
  if (!is.numeric(logy)) stop("`logy` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(logx) == 0L && length(logy) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(logx), length(logy))
  len <- .p_stage1_recycle_len(lens, "?logspace_sub")
  logxv <- rep_len(as.double(logx), len)
  logyv <- rep_len(as.double(logy), len)
  if (any(logyv > logxv)) {
    stop("`logy` must be <= `logx` elementwise after recycling.", call. = FALSE)
  }
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_sub_opencl(logxv, logyv, verbose = verbose),
    fallback_expr = function() logxv + log1p(-exp(logyv - logxv)),
    fallback = fallback, verbose = verbose, fn_name = "logspace_sub_opencl"
  )
}

#' @rdname rmath_runtime_opencl
#' @export
logspace_sum_opencl <- function(logx, logy, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(logx)) stop("`logx` must be numeric.")
  if (!is.numeric(logy)) stop("`logy` must be numeric.")
  .validate_flag(fallback, "fallback")
  .validate_flag(verbose, "verbose")
  if (length(logx) == 0L && length(logy) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(logx), length(logy))
  len <- .p_stage1_recycle_len(lens, "?logspace_sum")
  logxv <- rep_len(as.double(logx), len)
  logyv <- rep_len(as.double(logy), len)
  m <- pmax(logxv, logyv)
  .opencl_try_or_fallback(
    opencl_expr = function() .logspace_sum_opencl(logxv, logyv, verbose = verbose),
    fallback_expr = function() m + log1p(exp(pmin(logxv, logyv) - m)),
    fallback = fallback, verbose = verbose, fn_name = "logspace_sum_opencl"
  )
}
