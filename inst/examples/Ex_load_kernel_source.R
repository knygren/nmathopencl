############################### Start of load_kernel_source example ####################
# Kernel loading is provided by opencltools; pass package = "nmathopencl" for inst/cl.

if (requireNamespace("opencltools", quietly = TRUE)) {
  src <- opencltools::load_kernel_source("nmath/bd0.cl", package = "nmathopencl")
  lib <- opencltools::load_kernel_library("nmath", package = "nmathopencl")
  stopifnot(nzchar(src), nzchar(lib))
  cat("Loaded", nchar(src), "chars source and", nchar(lib), "chars nmath library.\n")
} else {
  message("opencltools not installed; skip example.")
}
## End of load_kernel_source example
