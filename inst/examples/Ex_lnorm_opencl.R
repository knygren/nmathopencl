if (has_opencl()) {
  n <- 5L

  dlnorm_opencl(n, x = 1.2, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  plnorm_opencl(q = 1.2, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  qlnorm_opencl(n, p = 0.8, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  rlnorm_opencl(n, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
