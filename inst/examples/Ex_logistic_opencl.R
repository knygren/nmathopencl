if (has_opencl()) {
  n <- 5L

  dlogis_opencl(n, x = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  plogis_opencl(q = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  qlogis_opencl(n, p = 0.8, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  rlogis_opencl(n, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
