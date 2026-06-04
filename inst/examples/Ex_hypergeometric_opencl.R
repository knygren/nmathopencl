# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dhyper_opencl(rep(3, n), m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  phyper_opencl(q = 3, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  qhyper_opencl(rep(0.8, n), m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  rhyper_opencl(n, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
} else {
  stats::dhyper(rep(3, n), m = 10, n = 12, k = 8)
  stats::phyper(3, m = 10, n = 12, k = 8)
  stats::qhyper(rep(0.8, n), m = 10, n = 12, k = 8)
  stats::rhyper(n, m = 10, n = 12, k = 8)
}
