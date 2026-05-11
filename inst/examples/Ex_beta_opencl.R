if (has_opencl()) {
  n <- 5L

  dbeta_opencl(n, x = 0.6, shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
  dnbeta_opencl(n, x = 0.6, shape1 = 2.5, shape2 = 4, ncp = 0.8, fallback = FALSE, verbose = TRUE)
  pbeta_opencl(n, x = 0.6, shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  qbeta_opencl(n, p = 0.8, shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  rbeta_opencl(n, shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
