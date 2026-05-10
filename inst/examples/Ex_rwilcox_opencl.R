if (has_opencl()) {
  # OpenCL Wilcoxon paths may require allocator/runtime symbols not always available.
  # Keeping this commented avoids flaky example failures across devices.
  # rwilcox_opencl(5, m = 5, nn = 7, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
