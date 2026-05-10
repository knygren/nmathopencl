if (has_opencl()) {
  n <- 5L

  r_pow_opencl(n, x = 1.2, y = 2, fallback = FALSE, verbose = TRUE)
  r_pow_di_opencl(n, x = 1.2, n_exp = 3L, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
