n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dweibull_opencl(rep(1.2, n), shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  pweibull_opencl(q = 1.2, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  qweibull_opencl(rep(0.8, n), shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
  rweibull_opencl(n, shape = 2, scale = 1.5, fallback = FALSE, verbose = TRUE)
} else {
  stats::dweibull(rep(1.2, n), shape = 2, scale = 1.5)
  stats::pweibull(1.2, shape = 2, scale = 1.5)
  stats::qweibull(rep(0.8, n), shape = 2, scale = 1.5)
  stats::rweibull(n, shape = 2, scale = 1.5)
}
