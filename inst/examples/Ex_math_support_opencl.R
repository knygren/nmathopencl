if (has_opencl()) {
  imax2_opencl(x = 7, y = 3, fallback = FALSE, verbose = TRUE)
  imin2_opencl(x = 7, y = 3, fallback = FALSE, verbose = TRUE)
  fmax2_opencl(x = 7.2, y = 3.1, fallback = FALSE, verbose = TRUE)
  fmin2_opencl(x = 7.2, y = 3.1, fallback = FALSE, verbose = TRUE)
  sign_opencl(x = -2.5, fallback = FALSE, verbose = TRUE)
  fprec_opencl(x = 123.456, digits = 4, fallback = FALSE, verbose = TRUE)
  fround_opencl(x = 123.456, digits = 2, fallback = FALSE, verbose = TRUE)
  fsign_opencl(x = -2.5, y = 4.0, fallback = FALSE, verbose = TRUE)
  ftrunc_opencl(x = 123.456, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
