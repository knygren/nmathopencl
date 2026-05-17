if (has_opencl()) {
  n <- 5L

  dunif_opencl(rep(0.4, n), min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  punif_opencl(q = 0.4, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  qunif_opencl(n, p = 0.8, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  runif_opencl(n, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
