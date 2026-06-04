n <- 5L
if (!nmathopencl_has_opencl() || identical(Sys.getenv("NOT_CRAN"), "true")) {
  r_check_user_interrupt_opencl(n, fallback = FALSE, verbose = TRUE)

  # Known linkage/runtime gap on some setups (stack hook symbol availability):
  # r_check_stack_opencl(n, fallback = FALSE, verbose = TRUE)
} else {
  as.numeric(seq_len(n))
}
