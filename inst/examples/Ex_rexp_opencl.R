if (has_opencl()) {
  rexp_opencl(5, rate = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
