#' Skip OpenCL GPU tests during CRAN `R CMD check` (and win-builder / R-hub).
#' CRAN builders may compile with OpenCL; GPU tests are for maintainer runs with
#' NOT_CRAN=true.
skip_opencl_gpu <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    isTRUE(nmathopencl::nmathopencl_has_opencl()),
    message = "OpenCL not available"
  )
}
