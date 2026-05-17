if (has_opencl()) {
  n <- 5L

  dcauchy_opencl(rep(0.2, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  pcauchy_opencl(q = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  qcauchy_opencl(rep(0.8, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  rcauchy_opencl(n, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
