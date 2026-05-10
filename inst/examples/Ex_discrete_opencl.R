n <- 5L

qbinom_opencl(n, p = 0.8, size = 20, prob = 0.3)
qpois_opencl(n, p = 0.8, lambda = 4)
qnbinom_mu_opencl(n, p = 0.8, size = 7, mu = 5)
rpois_opencl(n, lambda = 4)
