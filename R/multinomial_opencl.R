#' The Multinomial Distribution (OpenCL linkage subset)
#'
#' OpenCL-backed linkage wrapper for multinomial sampling. The current OpenCL
#' kernel supports a 2-category multinomial parameterization via scalar
#' \code{prob}, and returns a \code{2 x n} count matrix.
#'
#' @param n Number of observations. Non-negative integer scalar.
#' @param size Number of trials per draw (non-negative integer scalar).
#' @param prob Probability of the first category in \code{[0, 1]}.
#' @param fallback Logical; if \code{TRUE}, fall back to CPU behavior on OpenCL error.
#' @param verbose Logical; print fallback/error diagnostics.
#'
#' @return Integer matrix with 2 rows and \code{n} columns.
#' @example inst/examples/Ex_multinomial_opencl.R
#' @rdname multinomial_opencl
#' @export
rmultinom_opencl <- function(n, size, prob, fallback = TRUE, verbose = FALSE) {
  n <- .validate_n_scalar(n)
  if (!is.numeric(size) || length(size) != 1L || is.na(size) || size < 0 || size != as.integer(size)) {
    stop("`size` must be a non-negative integer scalar.")
  }
  size <- as.integer(size)
  .validate_scalar_num(prob, "prob", 0, 1)
  .validate_flag(fallback, "fallback"); .validate_flag(verbose, "verbose")

  fallback_expr <- function() stats::rmultinom(n, size = size, prob = c(prob, 1 - prob))
  out <- .opencl_try_or_fallback(
    opencl_expr = function() .rmultinom_opencl(n, size, prob, verbose = verbose),
    fallback_expr = function() fallback_expr(),
    fallback = fallback, verbose = verbose, fn_name = "rmultinom_opencl"
  )

  if (is.matrix(out)) return(out)
  if (!is.numeric(out) || length(out) != n) {
    stop("OpenCL rmultinom returned unexpected output shape.")
  }

  first <- as.integer(round(out))
  first[first < 0L] <- 0L
  first[first > size] <- size
  second <- size - first
  rbind(first, second)
}
