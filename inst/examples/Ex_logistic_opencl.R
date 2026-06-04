n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dlogis_opencl(rep(0.2, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  plogis_opencl(q = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  ## qlogis_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
  rlogis_opencl(n, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dlogis(rep(0.2, n), location = 0, scale = 1)
  stats::plogis(0.2, location = 0, scale = 1)
  stats::rlogis(n, location = 0, scale = 1)
}
