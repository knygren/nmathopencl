if (has_opencl()) {
  n <- 5L

  dweibull_opencl(rep(1.2, n), shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  pweibull_opencl(q = 1.2, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  qweibull_opencl(rep(0.8, n), shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  rweibull_opencl(n, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
