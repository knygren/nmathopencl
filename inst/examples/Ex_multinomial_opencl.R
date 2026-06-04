n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  rmultinom_opencl(n, size = 12L, prob = 0.4, fallback = FALSE, verbose = TRUE)
} else {
  stats::rmultinom(n, size = 12L, prob = c(0.4, 0.6))
}
