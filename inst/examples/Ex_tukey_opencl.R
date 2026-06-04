n <- 1L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  ptukey_opencl(q = 3.4, nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
  qtukey_opencl(rep(0.8, n), nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::ptukey(3.4, nmeans = 5, df = 10, nranges = 1)
  stats::qtukey(rep(0.8, n), nmeans = 5, df = 10, nranges = 1)
}
