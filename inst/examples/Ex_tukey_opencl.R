if (has_opencl()) {
  n <- 1L

  ptukey_opencl(q = 3.4, nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
  qtukey_opencl(rep(0.8, n), nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
