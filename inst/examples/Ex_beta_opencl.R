if (has_opencl()) {
  n <- 5L

  pbeta_opencl(n, x = 0.6, a = 2.5, b = 4, ncp = 1.1, fallback = FALSE, verbose = TRUE)
  qbeta_opencl(n, p = 0.8, a = 2.5, b = 4, ncp = 1.1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
