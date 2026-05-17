if (has_opencl()) {
  n <- 5L

  dgamma_opencl(rep(1.2, n), shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  pgamma_opencl(q = 1.2, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  qgamma_opencl(n, p = 0.8, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  rgamma_opencl(n, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
