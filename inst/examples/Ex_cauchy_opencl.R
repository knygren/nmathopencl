n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dcauchy_opencl(rep(0.2, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  pcauchy_opencl(q = 0.2, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  qcauchy_opencl(rep(0.8, n), location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
  rcauchy_opencl(n, location = 0, scale = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dcauchy(rep(0.2, n), location = 0, scale = 1)
  stats::pcauchy(0.2, location = 0, scale = 1)
  stats::qcauchy(rep(0.8, n), location = 0, scale = 1)
  stats::rcauchy(n, location = 0, scale = 1)
}
