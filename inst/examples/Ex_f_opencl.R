n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  df_opencl(rep(2, n), df1 = 5, df2 = 9, ncp = 0, fallback = FALSE, verbose = TRUE)
  df_opencl(rep(2, n), df1 = 5, df2 = 9, ncp = 1.1, fallback = FALSE, verbose = TRUE)
  pf_opencl(q = 2, df1 = 5, df2 = 9, ncp = 0, fallback = FALSE, verbose = TRUE)
  pf_opencl(q = 2, df1 = 5, df2 = 9, ncp = 1.1, fallback = FALSE, verbose = TRUE)
  rf_opencl(n, df1 = 5, df2 = 9, fallback = FALSE, verbose = TRUE)
  ## qf_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
} else {
  stats::df(rep(2, n), df1 = 5, df2 = 9, ncp = 0)
  stats::df(rep(2, n), df1 = 5, df2 = 9, ncp = 1.1)
  stats::pf(2, df1 = 5, df2 = 9, ncp = 0)
  stats::pf(2, df1 = 5, df2 = 9, ncp = 1.1)
  stats::rf(n, df1 = 5, df2 = 9)
}
