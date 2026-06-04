############################ Start of nmathopencl C API example ########################
# Installed header (for LinkingTo: nmathopencl):
hdr <- system.file(
  "include", "nmathopencl", "nmathopencl_capi.h",
  package = "nmathopencl"
)
stopifnot(nzchar(hdr), file.exists(hdr))
cat("nmathopencl C API header:", hdr, "\n")

# C-callables are registered in .onLoad (internal register_*; not exported).

# Downstream C++ includes the header and calls e.g. nmathopencl_dnorm_opencl()
# after library(nmathopencl) and library(opencltools).
############################ End of nmathopencl C API example ########################
