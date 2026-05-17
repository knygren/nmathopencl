if (has_opencl()) {
  n <- 5L

  dbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
  dnbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, ncp = 0.8, fallback = FALSE, verbose = TRUE)
  pbeta_opencl(q = 0.6, shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  ## qbeta_opencl: disabled — OpenCL build can fail with unresolved host symbol Rf_lbeta
  ##               (NVPTX/ptxas). Do not mask with fallback=TRUE; see
  ##               inst/OPENCL_KERNEL_KNOWN_FAILURES.md until the kernel/program is fixed.
  # qbeta_opencl(rep(0.8, n), shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  rbeta_opencl(n, shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
