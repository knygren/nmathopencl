n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
  dnbeta_opencl(rep(0.6, n), shape1 = 2.5, shape2 = 4, ncp = 0.8, fallback = FALSE, verbose = TRUE)
  pbeta_opencl(q = 0.6, shape1 = 2.5, shape2 = 4, ncp = 0, fallback = FALSE, verbose = TRUE)
  rbeta_opencl(n, shape1 = 2.5, shape2 = 4, fallback = FALSE, verbose = TRUE)
} else {
  stats::dbeta(rep(0.6, n), shape1 = 2.5, shape2 = 4)
  stats::pbeta(0.6, shape1 = 2.5, shape2 = 4, ncp = 0)
  stats::rbeta(n, shape1 = 2.5, shape2 = 4)
}
