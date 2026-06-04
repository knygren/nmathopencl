n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  norm_rand_opencl(n, fallback = FALSE, verbose = TRUE)
  unif_rand_opencl(n, fallback = FALSE, verbose = TRUE)
  r_unif_index_opencl(n, dn = 10, fallback = FALSE, verbose = TRUE)
  exp_rand_opencl(n, fallback = FALSE, verbose = TRUE)
} else {
  stats::rnorm(n)
  stats::runif(n)
  floor(stats::runif(n, min = 0, max = 10))
  stats::rexp(n)
}
