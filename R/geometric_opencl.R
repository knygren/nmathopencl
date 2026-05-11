#' The Geometric Distribution (OpenCL)
#'
#' OpenCL-backed density, distribution, quantile, and random generation wrappers
#' for the geometric distribution.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param x Numeric scalar quantile.
#' @param q Numeric scalar quantile.
#' @param p Numeric scalar probability in \code{[0, 1]}.
#' @param prob Probability of success in \code{[0, 1]}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Numeric vector of length \code{n}.
#' @example inst/examples/Ex_geometric_opencl.R
#' @rdname geometric_opencl
#' @export
dgeom_opencl <- function(n, x, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(x, "x", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .dgeom_opencl(n, x, prob, verbose = verbose),
    fallback_expr = function() rep(stats::dgeom(x, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "dgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
pgeom_opencl <- function(n, q, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(q, "q", 0, Inf)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .pgeom_opencl(n, q, prob, verbose = verbose),
    fallback_expr = function() rep(stats::pgeom(q, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "pgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
qgeom_opencl <- function(n, p, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(p, "p", 0, 1)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .qgeom_opencl(n, p, prob, verbose = verbose),
    fallback_expr = function() rep(stats::qgeom(p, prob = prob), n),
    fallback = fallback, verbose = verbose, fn_name = "qgeom_opencl"
  )
}

#' @rdname geometric_opencl
#' @export
rgeom_opencl <- function(n, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")
  .opencl_try_or_fallback(
    opencl_expr = function() .rgeom_opencl(n, prob, verbose = verbose),
    fallback_expr = function() stats::rgeom(n, prob = prob),
    fallback = fallback, verbose = verbose, fn_name = "rgeom_opencl"
  )
}
