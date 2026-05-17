if (has_opencl()) {
  n <- 5L

  dexp_opencl(rep(1.2, n), rate = 1, fallback = FALSE, verbose = TRUE)
  pexp_opencl(q = 1.2, rate = 1, fallback = FALSE, verbose = TRUE)
  qexp_opencl(n, p = 0.8, rate = 1, fallback = FALSE, verbose = TRUE)
  rexp_opencl(n, rate = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
