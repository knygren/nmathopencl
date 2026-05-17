if (has_opencl()) {
  n <- 5L

  df_opencl(n, x = 2, df1 = 5, df2 = 9, ncp = 0, fallback = FALSE, verbose = TRUE)
  df_opencl(n, x = 2, df1 = 5, df2 = 9, ncp = 1.1, fallback = FALSE, verbose = TRUE)
  pf_opencl(q = 2, df1 = 5, df2 = 9, ncp = 0, fallback = FALSE, verbose = TRUE)
  pf_opencl(q = 2, df1 = 5, df2 = 9, ncp = 1.1, fallback = FALSE, verbose = TRUE)
  rf_opencl(n, df1 = 5, df2 = 9, fallback = FALSE, verbose = TRUE)

  # Known unstable on some GPU/driver stacks (can hit CL_OUT_OF_RESOURCES):
  # qf_opencl(n, p = 0.8, df1 = 5, df2 = 9, ncp = 0, fallback = FALSE, verbose = TRUE)
  #
  # Known especially unstable non-central path:
  # qf_opencl(n, p = 0.8, df1 = 5, df2 = 9, ncp = 1.1, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
