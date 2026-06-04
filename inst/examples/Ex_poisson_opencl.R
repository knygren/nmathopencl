# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dpois_raw_opencl(rep(4, n), lambda = 4, fallback = FALSE, verbose = TRUE)
  dpois_opencl(rep(4, n), lambda = 4, fallback = FALSE, verbose = TRUE)
  ppois_opencl(q = 4, lambda = 4, fallback = FALSE, verbose = TRUE)
  qpois_opencl(rep(0.8, n), lambda = 4, fallback = FALSE, verbose = TRUE)
  rpois_opencl(n, lambda = 4, fallback = FALSE, verbose = TRUE)
} else {
  stats::dpois(rep(4, n), lambda = 4)
  stats::dpois(rep(4, n), lambda = 4)
  stats::ppois(4, lambda = 4)
  stats::qpois(rep(0.8, n), lambda = 4)
  stats::rpois(n, lambda = 4)
}
