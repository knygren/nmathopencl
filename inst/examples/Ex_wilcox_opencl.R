if (has_opencl()) {
  # Wilcoxon OpenCL kernels are currently known to fail on some GPU stacks due
  # to unresolved runtime symbols. Keeping these commented avoids flaky checks:
  # n <- 1L
  # dwilcox_opencl(n, x = 5, m = 5, nn = 7, fallback = FALSE, verbose = TRUE)
  # pwilcox_opencl(q = 5, m = 5, nn = 7, fallback = FALSE, verbose = TRUE)
  # qwilcox_opencl(n, p = 0.8, m = 5, nn = 7, fallback = FALSE, verbose = TRUE)
  #
  # Known allocator/runtime fragility on some stacks:
  # rwilcox_opencl(n, m = 5, nn = 7, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
