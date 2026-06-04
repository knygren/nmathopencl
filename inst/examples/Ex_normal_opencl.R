n <- 5L
x <- c(-1, 0, 1)
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dnorm_opencl(x, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  pnorm_opencl(q = 0.2, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  qnorm_opencl(rep(0.8, n), mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
  rnorm_opencl(n, mean = 0, sd = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dnorm(x, mean = 0, sd = 1)
  stats::pnorm(0.2, mean = 0, sd = 1)
  stats::qnorm(rep(0.8, n), mean = 0, sd = 1)
  stats::rnorm(n, mean = 0, sd = 1)
}
