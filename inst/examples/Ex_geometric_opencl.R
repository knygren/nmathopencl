# See ?nmathopencl_examples_use_opencl
n <- 5L
if (nmathopencl_examples_use_opencl()) {
  dgeom_opencl(rep(4, n), prob = 0.3, fallback = FALSE, verbose = TRUE)
  pgeom_opencl(q = 4, prob = 0.3, fallback = FALSE, verbose = TRUE)
  qgeom_opencl(rep(0.8, n), prob = 0.3, fallback = FALSE, verbose = TRUE)
  rgeom_opencl(n, prob = 0.3, fallback = FALSE, verbose = TRUE)
} else {
  stats::dgeom(rep(4, n), prob = 0.3)
  stats::pgeom(4, prob = 0.3)
  stats::qgeom(rep(0.8, n), prob = 0.3)
  stats::rgeom(n, prob = 0.3)
}
