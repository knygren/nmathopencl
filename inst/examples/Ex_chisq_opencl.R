if (has_opencl()) {
  n <- 5L

  dchisq_opencl(rep(4.5, n), df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  pchisq_opencl(q = 4.5, df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  qchisq_opencl(n, p = 0.8, df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  rchisq_opencl(n, df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
