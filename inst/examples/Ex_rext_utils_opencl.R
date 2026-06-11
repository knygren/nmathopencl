n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  r_check_user_interrupt_opencl(n, fallback = FALSE, verbose = TRUE)
} else {
  as.numeric(seq_len(n))
}
