n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dchisq_opencl(rep(4.5, n), df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  pchisq_opencl(q = 4.5, df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  qchisq_opencl(rep(0.8, n), df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
  rchisq_opencl(n, df = 6, ncp = 0, fallback = FALSE, verbose = TRUE)
} else {
  stats::dchisq(rep(4.5, n), df = 6, ncp = 0)
  stats::pchisq(4.5, df = 6, ncp = 0)
  stats::qchisq(rep(0.8, n), df = 6, ncp = 0)
  stats::rchisq(n, df = 6, ncp = 0)
}
