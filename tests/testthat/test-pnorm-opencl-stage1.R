test_that("pnorm_opencl matches stats recycling (vary q, mean, sd; scalar tails)", {
  skip_if_not(nmathopencl::has_opencl(), message = "OpenCL not available")

  q <- seq(-2, 2, length.out = 5)
  mu <- seq(0, 0.4, length.out = 5)
  sg <- seq(1, 1.4, length.out = 5)

  g <- nmathopencl::pnorm_opencl(
    q,
    mean = mu,
    sd = sg,
    lower.tail = TRUE,
    log.p = FALSE,
    fallback = FALSE,
    verbose = FALSE
  )
  cpu <- stats::pnorm(q, mean = mu, sd = sg, lower.tail = TRUE, log.p = FALSE)
  expect_equal(as.numeric(g), as.numeric(cpu), tolerance = 5e-12)
})

test_that("pnorm_opencl agrees with stats for zero-length quantiles with scalar defaults", {
  skip_if_not(nmathopencl::has_opencl(), message = "OpenCL not available")
  q <- numeric(0)
  expect_equal(as.numeric(stats::pnorm(q)), numeric(0))
  expect_equal(as.numeric(nmathopencl::pnorm_opencl(q)), numeric(0))
})
