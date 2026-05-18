#' Math Support Functions (OpenCL)
#'
#' OpenCL-backed wrappers for miscellaneous scalar support functions.
#'
#' @param x,y Numeric vectors recycled together (where both appear).
#' @param digits Numeric vector recycled with \code{x} for precision/rounding helpers.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of recycled common length.
#' @example inst/examples/Ex_math_support_opencl.R
#' @rdname math_support_opencl
#' @export
imax2_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) return(numeric(0))
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?imax2")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .imax2_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() as.double(pmax(as.integer(xv), as.integer(yv))),
    fallback = fallback, verbose = verbose, fn_name = "imax2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
imin2_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) return(numeric(0))
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?imin2")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .imin2_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() as.double(pmin(as.integer(xv), as.integer(yv))),
    fallback = fallback, verbose = verbose, fn_name = "imin2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fmax2_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) return(numeric(0))
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?fmax2")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .fmax2_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() pmax(xv, yv),
    fallback = fallback, verbose = verbose, fn_name = "fmax2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fmin2_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) return(numeric(0))
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?fmin2")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .fmin2_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() pmin(xv, yv),
    fallback = fallback, verbose = verbose, fn_name = "fmin2_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
sign_opencl <- function(x, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .sign_opencl(xv, verbose = verbose),
    fallback_expr = function() base::sign(xv),
    fallback = fallback, verbose = verbose, fn_name = "sign_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fprec_opencl <- function(x, digits, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(digits)) stop("`digits` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(digits) == 0L) return(numeric(0))
  lens <- c(length(x), length(digits))
  len <- .p_stage1_recycle_len(lens, "?fprec")
  xv <- rep_len(as.double(x), len)
  dv <- rep_len(digits, len)
  di <- as.integer(floor(dv))
  .opencl_try_or_fallback(
    opencl_expr = function() .fprec_opencl(xv, dv, verbose = verbose),
    fallback_expr = function() signif(xv, digits = di),
    fallback = fallback, verbose = verbose, fn_name = "fprec_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fround_opencl <- function(x, digits, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(digits)) stop("`digits` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(digits) == 0L) return(numeric(0))
  lens <- c(length(x), length(digits))
  len <- .p_stage1_recycle_len(lens, "?fround")
  xv <- rep_len(as.double(x), len)
  dv <- rep_len(digits, len)
  di <- as.integer(floor(dv))
  .opencl_try_or_fallback(
    opencl_expr = function() .fround_opencl(xv, dv, verbose = verbose),
    fallback_expr = function() base::round(xv, digits = di),
    fallback = fallback, verbose = verbose, fn_name = "fround_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
fsign_opencl <- function(x, y, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(y) == 0L) return(numeric(0))
  lens <- c(length(x), length(y))
  len <- .p_stage1_recycle_len(lens, "?fsign")
  xv <- rep_len(as.double(x), len)
  yv <- rep_len(as.double(y), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .fsign_opencl(xv, yv, verbose = verbose),
    fallback_expr = function() base::sign(xv) * abs(yv),
    fallback = fallback, verbose = verbose, fn_name = "fsign_opencl"
  )
}

#' @rdname math_support_opencl
#' @export
ftrunc_opencl <- function(x, fallback = TRUE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L) return(numeric(0))
  xv <- as.double(x)
  .opencl_try_or_fallback(
    opencl_expr = function() .ftrunc_opencl(xv, verbose = verbose),
    fallback_expr = function() base::trunc(xv),
    fallback = fallback, verbose = verbose, fn_name = "ftrunc_opencl"
  )
}
