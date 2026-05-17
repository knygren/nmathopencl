if (has_opencl()) {
  n <- 5L

  dt_opencl(rep(1.5, n), df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  dt_opencl(rep(1.5, n), df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  pt_opencl(q = 1.5, df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  pt_opencl(q = 1.5, df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  ## qt_opencl: disabled — OpenCL device link can fail on NVPTX (ptxas unresolved Rf_qnt;
  ##            Rmath qnt -> Rf_qnt naming vs device translation). Do not mask; see
  ##            inst/OPENCL_KERNEL_KNOWN_FAILURES.md until fixed.
  # qt_opencl(rep(0.8, n), df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  # qt_opencl(rep(0.8, n), df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  rt_opencl(n, df = 8, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
