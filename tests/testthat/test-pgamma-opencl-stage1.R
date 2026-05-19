test_that("pgamma_opencl matches stats recycling (vary q, shape, scale; scalar tails)", {
  skip_if_not(nmathopencl::has_opencl(), message = "OpenCL not available")

  q <- seq(0.5, 2.5, length.out = 5)
  sh <- seq(1.5, 2.5, length.out = 5)
  sc <- seq(1.1, 1.6, length.out = 5)

  g <- nmathopencl::pgamma_opencl(
    q,
    shape = sh,
    scale = sc,
    lower.tail = TRUE,
    log.p = FALSE,
    fallback = FALSE,
    verbose = FALSE
  )
  cpu <- stats::pgamma(q, shape = sh, scale = sc, lower.tail = TRUE, log.p = FALSE)
  expect_equal(as.numeric(g), as.numeric(cpu), tolerance = 5e-11)
})

test_that("pgamma_opencl lower.tail / log.p recycled row-wise (stats scalar-call refs)", {
  skip_if_not(nmathopencl::has_opencl(), message = "OpenCL not available")

  q <- c(0.3, 1.2, 2.1)
  sh <- c(2, 3, 4)
  lt <- c(TRUE, FALSE, TRUE)
  lp <- c(FALSE, TRUE, FALSE)

  g <- nmathopencl::pgamma_opencl(
    q,
    shape = sh,
    scale = 1,
    lower.tail = lt,
    log.p = lp,
    fallback = FALSE,
    verbose = FALSE
  )
  len <- max(length(q), length(sh), length(lt), length(lp))
  qv <- rep_len(q, len)
  shv <- rep_len(sh, len)
  ltv <- rep_len(lt, len)
  lpv <- rep_len(lp, len)
  cpu <- vapply(seq_len(len), function(i) {
    stats::pgamma(qv[i], shape = shv[i], scale = 1,
                  lower.tail = ltv[i], log.p = lpv[i])
  }, numeric(1L))
  expect_equal(as.numeric(g), as.numeric(cpu), tolerance = 5e-11)
})

test_that("pgamma_opencl agrees with stats for empty q", {
  skip_if_not(nmathopencl::has_opencl(), message = "OpenCL not available")
  q <- numeric(0)
  expect_equal(as.numeric(stats::pgamma(q, shape = 2)), numeric(0))
  expect_equal(as.numeric(nmathopencl::pgamma_opencl(q, shape = 2)), numeric(0))
})

test_that("pgamma_opencl rejects inconsistent rate and scale like stats", {
  expect_error(
    nmathopencl::pgamma_opencl(1, shape = 2, rate = 2, scale = 2, fallback = FALSE),
    "specify 'rate' or 'scale' but not both"
  )
})
