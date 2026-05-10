if (has_opencl()) {
  n <- 5L

  pchisq_opencl(n, x = 4.5, df = 6, ncp = 1.5, fallback = FALSE, verbose = TRUE)
  qchisq_opencl(n, p = 0.8, df = 6, ncp = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
