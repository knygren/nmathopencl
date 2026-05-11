if (has_opencl()) {
  n <- 5L

  dweibull_opencl(n, x = 1.2, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  pweibull_opencl(n, q = 1.2, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  qweibull_opencl(n, p = 0.8, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  rweibull_opencl(n, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
