n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dgamma_opencl(rep(1.2, n), shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  pgamma_opencl(q = 1.2, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  ## qgamma_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
  # qgamma_opencl(rep(0.8, n), shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
  rgamma_opencl(n, shape = 2, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dgamma(rep(1.2, n), shape = 2, scale = 1)
  stats::pgamma(1.2, shape = 2, scale = 1)
  stats::rgamma(n, shape = 2, scale = 1)
}
