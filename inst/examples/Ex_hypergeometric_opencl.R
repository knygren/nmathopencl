if (has_opencl()) {
  n <- 5L

  dhyper_opencl(n, x = 3, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  phyper_opencl(n, q = 3, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  qhyper_opencl(n, p = 0.8, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
  rhyper_opencl(n, m = 10, n_black = 12, k = 8, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
