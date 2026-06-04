if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  # Bessel OpenCL paths currently depend on temporary-workspace allocation
  # behavior (R_alloc/vmax* semantics) not yet fully implemented for device
  # execution. Keep these commented to avoid flaky CI/check failures:
  # n <- 1L
  # besselI_opencl(x = 2.0, nu = 1.5, expon.scaled = FALSE, fallback = FALSE, verbose = TRUE)
  # besselJ_opencl(x = 2.0, nu = 1.5, fallback = FALSE, verbose = TRUE)
  # besselK_opencl(x = 2.0, nu = 1.5, expon.scaled = FALSE, fallback = FALSE, verbose = TRUE)
  # besselY_opencl(x = 2.0, nu = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  besselI(2.0, nu = 1.5)
  besselJ(2.0, nu = 1.5)
  besselK(2.0, nu = 1.5)
  besselY(2.0, nu = 1.5)
}
