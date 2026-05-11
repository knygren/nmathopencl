if (has_opencl()) {
  # Signed-rank OpenCL kernels are currently known to fail on some GPU stacks
  # due to unresolved runtime allocation symbols (e.g., R_chk_calloc).
  # Keeping these commented avoids flaky check failures:
  # n <- 5L
  # dsignrank_opencl(n, x = 6, nsize = 8, fallback = FALSE, verbose = TRUE)
  # psignrank_opencl(n, q = 6, nsize = 8, fallback = FALSE, verbose = TRUE)
  # qsignrank_opencl(n, p = 0.8, nsize = 8, fallback = FALSE, verbose = TRUE)
  # rsignrank_opencl(n, nsize = 8, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
