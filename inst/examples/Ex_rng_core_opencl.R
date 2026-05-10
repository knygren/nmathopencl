if (has_opencl()) {
  n <- 5L

  norm_rand_opencl(n, fallback = FALSE, verbose = TRUE)
  unif_rand_opencl(n, fallback = FALSE, verbose = TRUE)
  r_unif_index_opencl(n, dn = 10, fallback = FALSE, verbose = TRUE)
  exp_rand_opencl(n, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
