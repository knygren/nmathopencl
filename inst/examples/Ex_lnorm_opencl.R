n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dlnorm_opencl(rep(1.2, n), meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  plnorm_opencl(q = 1.2, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  qlnorm_opencl(rep(0.8, n), meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
  rlnorm_opencl(n, meanlog = 0.1, sdlog = 0.8, fallback = FALSE, verbose = TRUE)
} else {
  stats::dlnorm(rep(1.2, n), meanlog = 0.1, sdlog = 0.8)
  stats::plnorm(1.2, meanlog = 0.1, sdlog = 0.8)
  stats::qlnorm(rep(0.8, n), meanlog = 0.1, sdlog = 0.8)
  stats::rlnorm(n, meanlog = 0.1, sdlog = 0.8)
}
