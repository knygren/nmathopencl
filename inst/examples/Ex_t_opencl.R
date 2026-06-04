# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dt_opencl(rep(1.5, n), df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  dt_opencl(rep(1.5, n), df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  pt_opencl(q = 1.5, df = 8, ncp = 0, fallback = FALSE, verbose = TRUE)
  pt_opencl(q = 1.5, df = 8, ncp = 1.2, fallback = FALSE, verbose = TRUE)
  ## qt_opencl: disabled — see inst/OPENCL_KERNEL_KNOWN_FAILURES.md
  rt_opencl(n, df = 8, fallback = FALSE, verbose = TRUE)
} else {
  stats::dt(rep(1.5, n), df = 8, ncp = 0)
  stats::dt(rep(1.5, n), df = 8, ncp = 1.2)
  stats::pt(1.5, df = 8, ncp = 0)
  stats::pt(1.5, df = 8, ncp = 1.2)
  stats::rt(n, df = 8)
}
