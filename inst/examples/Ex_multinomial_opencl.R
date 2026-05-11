if (has_opencl()) {
  n <- 5L

  rmultinom_opencl(n, size = 12L, prob = 0.4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
