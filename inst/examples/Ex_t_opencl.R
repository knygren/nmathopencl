if (has_opencl()) {
  n <- 5L

  pt_opencl(n, x = 1.5, df = 8, ncp = 0.7, fallback = FALSE, verbose = TRUE)
  qt_opencl(n, p = 0.8, df = 8, ncp = 0.7, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
