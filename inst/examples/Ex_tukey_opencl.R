# See ?nmathopencl_examples_use_opencl
n <- 1L
if (nmathopencl_examples_use_opencl()) {
  ptukey_opencl(q = 3.4, nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
  qtukey_opencl(rep(0.8, n), nmeans = 5, df = 10, nranges = 1, fallback = FALSE, verbose = TRUE)
} else {
  stats::ptukey(3.4, nmeans = 5, df = 10, nranges = 1)
  stats::qtukey(rep(0.8, n), nmeans = 5, df = 10, nranges = 1)
}
