## Append NA_real_ to quantile vectors so `any(!is.finite(qv))` selects the row-wise CPU
## fallback before OpenCL dispatch (keeps tests fast while exercising Stage-1 recycling).

pad_na_vec <- function(z) {
  c(as.numeric(z), NA_real_)
}

test_that("stage-1 p* wrappers match stats recycling (continuous families, CPU guard)", {
  tol <- 5e-11

  qq <- pad_na_vec(c(0.05, 0.72))
  mn <- pad_na_vec(c(-1, 0))
  mx <- pad_na_vec(c(2, 3))
  lt <- c(TRUE, FALSE)
  lp <- c(FALSE, TRUE)
  got <- nmathopencl::punif_opencl(qq, min = mn, max = mx, lower.tail = lt, log.p = lp, fallback = FALSE)
  len <- length(qq)
  ltv <- rep_len(lt, len)
  lpv <- rep_len(lp, len)
  ref <- vapply(seq_len(len), function(i) {
    stats::punif(qq[i], min = mn[i], max = mx[i], lower.tail = ltv[i], log.p = lpv[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(0.15, 0.82))
  sh1 <- pad_na_vec(c(2.1, 3.2))
  sh2 <- pad_na_vec(c(4.0, 5.5))
  nc <- pad_na_vec(c(0, 0.4))
  got <- nmathopencl::pbeta_opencl(qq, shape1 = sh1, shape2 = sh2, ncp = nc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pbeta(qq[i], shape1 = sh1[i], shape2 = sh2[i], ncp = nc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(1.2, 6.4))
  df <- pad_na_vec(c(4, 7))
  nc <- pad_na_vec(c(0, 0.5))
  got <- nmathopencl::pchisq_opencl(qq, df = df, ncp = nc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pchisq(qq[i], df = df[i], ncp = nc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(0.7, 2.8))
  d1 <- pad_na_vec(c(6, 10))
  d2 <- pad_na_vec(c(12, 12))
  nc <- pad_na_vec(c(0, 1.5))
  lt <- c(TRUE, FALSE)
  lp <- c(FALSE, TRUE)
  got <- nmathopencl::pf_opencl(qq, df1 = d1, df2 = d2, ncp = nc,
                                lower.tail = lt, log.p = lp, fallback = FALSE)
  len <- length(qq)
  ltv <- rep_len(lt, len)
  lpv <- rep_len(lp, len)
  ref <- vapply(seq_len(len), function(i) {
    stats::pf(qq[i], df1 = d1[i], df2 = d2[i], ncp = nc[i],
              lower.tail = ltv[i], log.p = lpv[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(-1.5, 2.2))
  df <- pad_na_vec(c(9, 11))
  nc <- pad_na_vec(c(0, 1))
  got <- nmathopencl::pt_opencl(qq, df = df, ncp = nc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pt(qq[i], df = df[i], ncp = nc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(0.1, -0.7))
  loc <- pad_na_vec(c(0, -0.5))
  sc <- pad_na_vec(c(1.2, 2))
  got <- nmathopencl::pcauchy_opencl(qq, location = loc, scale = sc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pcauchy(qq[i], location = loc[i], scale = sc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(0.35, 2.5))
  rt <- pad_na_vec(c(1.5, 2))
  got <- nmathopencl::pexp_opencl(qq, rate = rt, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pexp(qq[i], rate = rt[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(1.05, 2.8))
  sh <- pad_na_vec(c(2.5, 3))
  sc <- pad_na_vec(c(1.4, 1.3))
  got <- nmathopencl::pweibull_opencl(qq, shape = sh, scale = sc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::pweibull(qq[i], shape = sh[i], scale = sc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(0.8, 4))
  ml <- pad_na_vec(c(0.2, 0.7))
  sl <- pad_na_vec(c(0.9, 1.2))
  got <- nmathopencl::plnorm_opencl(qq, meanlog = ml, sdlog = sl, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::plnorm(qq[i], meanlog = ml[i], sdlog = sl[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(-1.5, 1))
  loc <- pad_na_vec(c(0.5, -0.25))
  sc <- pad_na_vec(c(2.5, 2))
  got <- nmathopencl::plogis_opencl(qq, location = loc, scale = sc, fallback = FALSE)
  ref <- vapply(seq_along(qq), function(i) {
    stats::plogis(qq[i], location = loc[i], scale = sc[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = tol)

  qq <- pad_na_vec(c(2.8, 4.2))
  nm <- pad_na_vec(c(5, 7))
  df <- pad_na_vec(c(18, 22))
  nr <- c(1L, 2L)
  lt <- c(TRUE, FALSE)
  lp <- c(FALSE, TRUE)
  got <- nmathopencl::ptukey_opencl(qq, nmeans = nm, df = df, nranges = nr,
                                    lower.tail = lt, log.p = lp, fallback = FALSE)
  len <- length(qq)
  ltv <- rep_len(lt, len)
  lpv <- rep_len(lp, len)
  nrv <- rep_len(nr, len)
  ref <- vapply(seq_len(len), function(i) {
    stats::ptukey(qq[i], nmeans = nm[i], df = df[i], nranges = nrv[i],
                  lower.tail = ltv[i], log.p = lpv[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref, tolerance = 5e-10)
})

test_that("stage-1 p* wrappers match stats recycling (discrete families, CPU guard)", {
  qs <- pad_na_vec(c(3, 8))
  sz <- pad_na_vec(c(12, 14))
  pr <- pad_na_vec(c(0.35, 0.42))
  got <- nmathopencl::pbinom_opencl(qs, size = sz, prob = pr, fallback = FALSE)
  ref <- vapply(seq_along(qs), function(i) {
    stats::pbinom(qs[i], size = sz[i], prob = pr[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)

  qs <- pad_na_vec(c(4, 10))
  sz <- pad_na_vec(c(8, 10))
  pr <- pad_na_vec(c(0.55, 0.42))
  got <- nmathopencl::pnbinom_opencl(qs, size = sz, prob = pr, fallback = FALSE)
  ref <- vapply(seq_along(qs), function(i) {
    stats::pnbinom(qs[i], size = sz[i], prob = pr[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)

  qs <- pad_na_vec(c(4, 10))
  sz <- pad_na_vec(c(8, 10))
  mu <- pad_na_vec(c(5.5, 6))
  got <- nmathopencl::pnbinom_mu_opencl(qs, size = sz, mu = mu, fallback = FALSE)
  ref <- vapply(seq_along(qs), function(i) {
    stats::pnbinom(qs[i], size = sz[i], mu = mu[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)

  qs <- pad_na_vec(c(2, 7))
  lam <- pad_na_vec(c(3.5, 5))
  got <- nmathopencl::ppois_opencl(qs, lambda = lam, fallback = FALSE)
  ref <- vapply(seq_along(qs), function(i) {
    stats::ppois(qs[i], lambda = lam[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)

  qs <- pad_na_vec(c(3, 9))
  pb <- pad_na_vec(c(0.35, 0.42))
  got <- nmathopencl::pgeom_opencl(qs, prob = pb, fallback = FALSE)
  ref <- vapply(seq_along(qs), function(i) {
    stats::pgeom(qs[i], prob = pb[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)

  qs <- pad_na_vec(c(3, 5))
  m <- pad_na_vec(c(14, 18))
  nb <- pad_na_vec(c(20, 22))
  kk <- pad_na_vec(c(12, 14))
  lt <- c(TRUE, FALSE)
  got <- nmathopencl::phyper_opencl(qs, m = m, n_black = nb, k = kk, lower.tail = lt, fallback = FALSE)
  len <- length(qs)
  ltv <- rep_len(lt, len)
  ref <- vapply(seq_len(len), function(i) {
    stats::phyper(qs[i], m = m[i], n = nb[i], k = kk[i], lower.tail = ltv[i])
  }, numeric(1L))
  expect_equal(as.numeric(got), ref)
})
