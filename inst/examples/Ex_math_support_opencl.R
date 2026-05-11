if (has_opencl()) {
  n <- 5L

  imax2_opencl(n, x = 7, y = 3, fallback = FALSE, verbose = TRUE)
  imin2_opencl(n, x = 7, y = 3, fallback = FALSE, verbose = TRUE)
  fmax2_opencl(n, x = 7.2, y = 3.1, fallback = FALSE, verbose = TRUE)
  fmin2_opencl(n, x = 7.2, y = 3.1, fallback = FALSE, verbose = TRUE)
  sign_opencl(n, x = -2.5, fallback = FALSE, verbose = TRUE)
  fprec_opencl(n, x = 123.456, digits = 4, fallback = FALSE, verbose = TRUE)
  fround_opencl(n, x = 123.456, digits = 2, fallback = FALSE, verbose = TRUE)
  fsign_opencl(n, x = -2.5, y = 4.0, fallback = FALSE, verbose = TRUE)
  ftrunc_opencl(n, x = 123.456, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
