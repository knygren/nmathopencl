if (has_opencl()) {
  n <- 5L

  r_pow_opencl(n, x = 1.2, y = 2, fallback = FALSE, verbose = TRUE)
  r_pow_di_opencl(n, x = 1.2, n_exp = 3L, fallback = FALSE, verbose = TRUE)
  log1pmx_opencl(n, x = 0.2, fallback = FALSE, verbose = TRUE)
  log1pexp_opencl(n, x = 0.2, fallback = FALSE, verbose = TRUE)
  log1mexp_opencl(n, x = 0.5, fallback = FALSE, verbose = TRUE)
  lgamma1p_opencl(n, x = 0.2, fallback = FALSE, verbose = TRUE)
  pow1p_opencl(n, x = 0.2, y = 3, fallback = FALSE, verbose = TRUE)
  logspace_add_opencl(n, logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
  logspace_sub_opencl(n, logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
  logspace_sum_opencl(n, logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
