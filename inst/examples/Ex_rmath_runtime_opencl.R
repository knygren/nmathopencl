# See ?nmathopencl_examples_use_opencl
if (nmathopencl_examples_use_opencl()) {
  r_pow_opencl(x = 1.2, y = 2, fallback = FALSE, verbose = TRUE)
  r_pow_di_opencl(x = 1.2, n_exp = 3L, fallback = FALSE, verbose = TRUE)
  log1pmx_opencl(x = 0.2, fallback = FALSE, verbose = TRUE)
  log1pexp_opencl(x = 0.2, fallback = FALSE, verbose = TRUE)
  log1mexp_opencl(x = 0.5, fallback = FALSE, verbose = TRUE)
  lgamma1p_opencl(x = 0.2, fallback = FALSE, verbose = TRUE)
  pow1p_opencl(x = 0.2, y = 3, fallback = FALSE, verbose = TRUE)
  logspace_add_opencl(logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
  logspace_sub_opencl(logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
  logspace_sum_opencl(logx = -2, logy = -3, fallback = FALSE, verbose = TRUE)
  log1pmx_opencl(x = seq(-0.5, 0.5, by = 0.25), fallback = FALSE, verbose = TRUE)
} else {
  (1.2 + seq_len(1L) * 1e-3)^2
  1.2^3
  log1p(0.2) - 0.2
  ifelse(0.2 > 0, 0.2 + log1p(exp(-0.2)), log1p(exp(0.2)))
  ifelse(0.5 <= log(2), log(-expm1(-0.5)), log1p(-exp(-0.5)))
  lgamma(1.2)
  exp(3 * log1p(0.2))
  {
    m <- max(-2, -3)
    m + log1p(exp(min(-2, -3) - m))
  }
  -2 + log1p(-exp(-3 - (-2)))
  {
    m <- max(-2, -3)
    m + log1p(exp(min(-2, -3) - m))
  }
  {
    xv <- seq(-0.5, 0.5, by = 0.25)
    log1p(xv) - xv
  }
}
