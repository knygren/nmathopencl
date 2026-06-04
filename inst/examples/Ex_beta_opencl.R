# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
  dnbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, ncp = 0.8, fallback = FALSE, verbose = TRUE)
  pbeta_opencl(q = 0.6, shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  ## qbeta_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
  # qbeta_opencl(rep(0.8, n), shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  rbeta_opencl(n, shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
} else {
  stats::dbeta(rep(0.6, n), shape1 = 2.5, shape2 = 4)
  stats::dnbeta(rep(0.6, n), shape1 = 2.5, shape2 = 4, ncp = 0.8)
  stats::pbeta(0.6, shape1 = 2.5, shape2 = 4)
  stats::rbeta(n, shape1 = 2.5, shape2 = 4)
}
