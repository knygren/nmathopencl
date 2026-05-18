if (has_opencl()) {
  gammafn_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  lgammafn_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  digamma_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  trigamma_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  tetragamma_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  pentagamma_opencl(x = 2.5, fallback = FALSE, verbose = TRUE)
  psigamma_opencl(x = 2.5, deriv = 1, fallback = FALSE, verbose = TRUE)

  beta_opencl(a = 2.5, b = 3.0, fallback = FALSE, verbose = TRUE)
  lbeta_opencl(a = 2.5, b = 3.0, fallback = FALSE, verbose = TRUE)
  choose_opencl(n = 10, k = 4, fallback = FALSE, verbose = TRUE)
  lchoose_opencl(n = 10, k = 4, fallback = FALSE, verbose = TRUE)
} else {
  message("OpenCL unavailable; skipping GPU-only example.")
}
