if (has_opencl()) {
  n <- 5L

  dt_opencl(n, x = 1.5, df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  dt_opencl(n, x = 1.5, df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  pt_opencl(n, x = 1.5, df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  pt_opencl(n, x = 1.5, df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  qt_opencl(n, p = 0.8, df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  qt_opencl(n, p = 0.8, df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  rt_opencl(n, df = 8, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
