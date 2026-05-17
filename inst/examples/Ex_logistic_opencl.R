if (has_opencl()) {
  n <- 5L

  dlogis_opencl(rep(0.2, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  plogis_opencl(q = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  ## qlogis_opencl: disabled — OpenCL device link can fail (NVPTX/ptxas unresolved Rf_qlogis;
  ##               Rmath qlogis->Rf_qlogis naming vs ported qlogis.cl symbol). Do not mask; see
  ##               inst/OPENCL_KERNEL_KNOWN_FAILURES.md until fixed.
  # qlogis_opencl(rep(0.8, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  rlogis_opencl(n, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
