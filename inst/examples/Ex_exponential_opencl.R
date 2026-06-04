# *_opencl when CPU-only or off CRAN; plain stats on CRAN with OpenCL (timing).
# Set NOT_CRAN=true locally / on rhub to exercise the OpenCL wrappers.
n <- 5L
if (!has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  dexp_opencl(rep(1.2, n), rate = 1, fallback = FALSE, verbose = TRUE)
  pexp_opencl(q = 1.2, rate = 1, fallback = FALSE, verbose = TRUE)
  qexp_opencl(rep(0.8, n), rate = 1, fallback = FALSE, verbose = TRUE)
  rexp_opencl(n, rate = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::dexp(rep(1.2, n), rate = 1)
  stats::pexp(1.2, rate = 1)
  stats::qexp(rep(0.8, n), rate = 1)
  stats::rexp(n, rate = 1)
}
