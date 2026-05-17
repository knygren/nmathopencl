if (has_opencl()) {
  n <- 5L
  x <- c(-1, 0, 1)

  dnorm_opencl(x, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  pnorm_opencl(q = 0.2, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  qnorm_opencl(rep(0.8, n), mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  rnorm_opencl(n, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
