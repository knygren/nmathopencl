#' Bessel Functions (OpenCL)
#'
#' OpenCL-backed wrappers for Bessel functions.
#'
#' @param x,nu Numeric vectors recycled together.
#' @param expon.scaled Logical vector recycled with \code{x} and \code{nu} where applicable;
#'   maps to the \code{expon.scaled} flag in \code{\link[base]{besselI}} /
#'   \code{\link[base]{besselK}}.
#' @param fallback When \code{TRUE} while \code{\link{has_opencl}()} reports OpenCL present, recover with CPU if the OpenCL call fails. Ignored when the runtime reports no OpenCL (CPU path is chosen automatically). Defaults to \code{FALSE}.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @section Known OpenCL limitations:
#' Current Bessel OpenCL paths may require temporary-workspace allocation
#' semantics equivalent to host \code{R_alloc}/\code{vmax*} behavior. On some
#' GPU stacks this can fail at runtime; use \code{fallback = TRUE} if you must
#' tolerate failures until device-side workspace handling is implemented.
#'
#' @return Numeric vector of recycled common length.
#' @example inst/examples/Ex_bessel_opencl.R
#' @rdname bessel_opencl
#' @export
besselI_opencl <- function(x, nu, expon.scaled = FALSE, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(nu)) stop("`nu` must be numeric.")
  if (!is.logical(expon.scaled)) stop("`expon.scaled` must be logical.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(nu) == 0L && length(expon.scaled) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(x), length(nu), length(expon.scaled))
  len <- .p_stage1_recycle_len(lens, "?besselI")
  xv <- rep_len(as.double(x), len)
  nv <- rep_len(as.double(nu), len)
  ev <- rep_len(expon.scaled, len)
  expo <- as.double(ev)
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_i_opencl(xv, nv, expo, verbose = verbose),
    fallback_expr = function() base::besselI(xv, nu = nv, expon.scaled = ev),
    fallback = fallback, verbose = verbose, fn_name = "besselI_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselJ_opencl <- function(x, nu, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(nu)) stop("`nu` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(nu) == 0L) return(numeric(0))
  lens <- c(length(x), length(nu))
  len <- .p_stage1_recycle_len(lens, "?besselJ")
  xv <- rep_len(as.double(x), len)
  nv <- rep_len(as.double(nu), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_j_opencl(xv, nv, verbose = verbose),
    fallback_expr = function() base::besselJ(xv, nu = nv),
    fallback = fallback, verbose = verbose, fn_name = "besselJ_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselK_opencl <- function(x, nu, expon.scaled = FALSE, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(nu)) stop("`nu` must be numeric.")
  if (!is.logical(expon.scaled)) stop("`expon.scaled` must be logical.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(nu) == 0L && length(expon.scaled) == 0L) {
    return(numeric(0))
  }
  lens <- c(length(x), length(nu), length(expon.scaled))
  len <- .p_stage1_recycle_len(lens, "?besselK")
  xv <- rep_len(as.double(x), len)
  nv <- rep_len(as.double(nu), len)
  ev <- rep_len(expon.scaled, len)
  expo <- as.double(ev)
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_k_opencl(xv, nv, expo, verbose = verbose),
    fallback_expr = function() base::besselK(xv, nu = nv, expon.scaled = ev),
    fallback = fallback, verbose = verbose, fn_name = "besselK_opencl"
  )
}

#' @rdname bessel_opencl
#' @export
besselY_opencl <- function(x, nu, fallback = FALSE, verbose = FALSE) {
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(nu)) stop("`nu` must be numeric.")
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  if (length(x) == 0L && length(nu) == 0L) return(numeric(0))
  lens <- c(length(x), length(nu))
  len <- .p_stage1_recycle_len(lens, "?besselY")
  xv <- rep_len(as.double(x), len)
  nv <- rep_len(as.double(nu), len)
  .opencl_try_or_fallback(
    opencl_expr = function() .bessel_y_opencl(xv, nv, verbose = verbose),
    fallback_expr = function() base::besselY(xv, nu = nv),
    fallback = fallback, verbose = verbose, fn_name = "besselY_opencl"
  )
}
