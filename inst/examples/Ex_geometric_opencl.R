if (has_opencl()) {
  n <- 5L

  dgeom_opencl(n, x = 4, prob = 0.3, fallback = FALSE, verbose = TRUE)
  pgeom_opencl(n, q = 4, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qgeom_opencl(n, p = 0.8, prob = 0.3, fallback = FALSE, verbose = TRUE)
  rgeom_opencl(n, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
