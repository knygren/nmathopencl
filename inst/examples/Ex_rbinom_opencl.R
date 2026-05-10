if (has_opencl()) {
  rbinom_opencl(5, size = 10, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
