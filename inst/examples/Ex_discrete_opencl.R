if (has_opencl()) {
  n <- 5L

  qbinom_opencl(n, p = 0.8, size = 20, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qpois_opencl(n, p = 0.8, lambda = 4, fallback = FALSE, verbose = TRUE)
  qnbinom_mu_opencl(n, p = 0.8, size = 7, mu = 5, fallback = FALSE, verbose = TRUE)
  rpois_opencl(n, lambda = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
