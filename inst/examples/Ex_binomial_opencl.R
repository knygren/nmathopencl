# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dbinom_raw_opencl(rep(6, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  dbinom_opencl(rep(6, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  pbinom_opencl(q = 6, size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qbinom_opencl(rep(0.8, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  rbinom_opencl(n, size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  stats::dbinom(rep(6, n), size = 10, prob = 0.3)
  stats::dbinom(rep(6, n), size = 10, prob = 0.3)
  stats::pbinom(6, size = 10, prob = 0.3)
  stats::qbinom(rep(0.8, n), size = 10, prob = 0.3)
  stats::rbinom(n, size = 10, prob = 0.3)
}
