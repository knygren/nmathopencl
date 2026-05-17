if (has_opencl()) {
  n <- 5L

  dunif_opencl(rep(0.4, n), min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  punif_opencl(q = 0.4, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  ## qunif_opencl: disabled — NVPTX/ptxas can fail (unresolved Rf_qunif; Rmath qunif -> Rf_qunif).
  ##                See inst/OPENCL_KERNEL_KNOWN_FAILURES.md until fixed.
  # qunif_opencl(rep(0.8, n), min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  runif_opencl(n, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
