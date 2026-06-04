n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dunif_opencl(rep(0.4, n), min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  punif_opencl(q = 0.4, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
  ## qunif_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
  runif_opencl(n, min = 0, max = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dunif(rep(0.4, n), min = 0, max = 1)
  stats::punif(0.4, min = 0, max = 1)
  stats::runif(n, min = 0, max = 1)
}
