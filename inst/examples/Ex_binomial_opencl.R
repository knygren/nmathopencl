if (has_opencl()) {
  n <- 5L

  dbinom_raw_opencl(rep(6, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  dbinom_opencl(rep(6, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  pbinom_opencl(q = 6, size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qbinom_opencl(rep(0.8, n), size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
  rbinom_opencl(n, size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
