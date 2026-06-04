n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dnbinom_opencl(rep(4, n), size = 7, prob = 0.4, fallback = FALSE, verbose = TRUE)
  pnbinom_opencl(q = 4, size = 7, prob = 0.4, fallback = FALSE, verbose = TRUE)
  qnbinom_opencl(rep(0.8, n), size = 7, prob = 0.4, fallback = FALSE, verbose = TRUE)
  rnbinom_opencl(n, size = 7, prob = 0.4, fallback = FALSE, verbose = TRUE)

  dnbinom_mu_opencl(rep(4, n), size = 7, mu = 5, fallback = FALSE, verbose = TRUE)
  pnbinom_mu_opencl(q = 4, size = 7, mu = 5, fallback = FALSE, verbose = TRUE)
  qnbinom_mu_opencl(rep(0.8, n), size = 7, mu = 5, fallback = FALSE, verbose = TRUE)
  rnbinom_mu_opencl(n, size = 7, mu = 5, fallback = FALSE, verbose = TRUE)
} else {
  stats::dnbinom(rep(4, n), size = 7, prob = 0.4)
  stats::pnbinom(4, size = 7, prob = 0.4)
  stats::qnbinom(rep(0.8, n), size = 7, prob = 0.4)
  stats::rnbinom(n, size = 7, prob = 0.4)

  stats::dnbinom(rep(4, n), size = 7, mu = 5)
  stats::pnbinom(4, size = 7, mu = 5)
  stats::qnbinom(rep(0.8, n), size = 7, mu = 5)
  stats::rnbinom(n, size = 7, mu = 5)
}
