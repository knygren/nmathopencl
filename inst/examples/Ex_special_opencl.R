if (has_opencl()) {
  n <- 5L

  gammafn_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  lgammafn_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  digamma_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  trigamma_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  tetragamma_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  pentagamma_opencl(n, x = 2.5, fallback = FALSE, verbose = TRUE)
  psigamma_opencl(n, x = 2.5, deriv = 1, fallback = FALSE, verbose = TRUE)

  beta_opencl(n, a = 2.5, b = 3.0, fallback = FALSE, verbose = TRUE)
  lbeta_opencl(n, a = 2.5, b = 3.0, fallback = FALSE, verbose = TRUE)
  choose_opencl(n, x = 10, k = 4, fallback = FALSE, verbose = TRUE)
  lchoose_opencl(n, x = 10, k = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
