# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  rmultinom_opencl(n, size = 12L, prob = 0.4, fallback = FALSE, verbose = TRUE)
} else {
  stats::rmultinom(n, size = 12L, prob = c(0.4, 0.6))
}
