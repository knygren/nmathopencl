if (has_opencl()) {
  n <- 5L

  dgamma_opencl(rep(1.2, n), shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  pgamma_opencl(q = 1.2, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  ## qgamma_opencl: disabled — OpenCL build can fail with unresolved host symbol stirlerr_cycle_free
  ##               (NVPTX/ptxas; nmath Stirling tails in qgamma). Do not mask; see
  ##               inst/OPENCL_KERNEL_KNOWN_FAILURES.md until fixed.
  # qgamma_opencl(rep(0.8, n), shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  rgamma_opencl(n, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
