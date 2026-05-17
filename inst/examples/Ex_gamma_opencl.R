if (has_opencl()) {
  dgamma_opencl(n = 5L, x = 1.2, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  pgamma_opencl(q = 1.2, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  qgamma_opencl(n = 5L, p = 0.8, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  rgamma_opencl(n = 5L, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
