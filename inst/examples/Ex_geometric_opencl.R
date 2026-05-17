if (has_opencl()) {
  n <- 5L

  dgeom_opencl(rep(4, n), prob = 0.3, fallback = FALSE, verbose = TRUE)
  pgeom_opencl(q = 4, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qgeom_opencl(rep(0.8, n), prob = 0.3, fallback = FALSE, verbose = TRUE)
  rgeom_opencl(n, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
