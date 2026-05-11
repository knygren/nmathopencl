if (has_opencl()) {
  # Bessel OpenCL paths currently depend on temporary-workspace allocation
  # behavior (R_alloc/vmax* semantics) not yet fully implemented for device
  # execution. Keep these commented to avoid flaky CI/check failures:
  # n <- 1L
  # besselI_opencl(n, x = 2.0, nu = 1.5, expon.scaled = FALSE, fallback = FALSE, verbose = TRUE)
  # besselJ_opencl(n, x = 2.0, nu = 1.5, fallback = FALSE, verbose = TRUE)
  # besselK_opencl(n, x = 2.0, nu = 1.5, expon.scaled = FALSE, fallback = FALSE, verbose = TRUE)
  # besselY_opencl(n, x = 2.0, nu = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
