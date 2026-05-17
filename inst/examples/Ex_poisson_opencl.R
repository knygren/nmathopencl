if (has_opencl()) {
  n <- 5L

  dpois_raw_opencl(n, x = 4, lambda = 4, fallback = FALSE, verbose = TRUE)
  dpois_opencl(n, x = 4, lambda = 4, fallback = FALSE, verbose = TRUE)
  ppois_opencl(q = 4, lambda = 4, fallback = FALSE, verbose = TRUE)
  qpois_opencl(n, p = 0.8, lambda = 4, fallback = FALSE, verbose = TRUE)
  rpois_opencl(n, lambda = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
