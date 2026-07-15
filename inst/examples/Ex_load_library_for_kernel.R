############################ Start of load_library_for_kernel example ########################

# In a full OpenCL program build, prepend opencltools::load_program_preload()
# and append opencltools::load_kernel_source(); see Ex_load_program_preload.R.

\donttest{
lib_dir <- system.file("cl/nmath", package = "nmathopencl")
kpath <- system.file("cl/src/dnorm_kernel.cl", package = "nmathopencl")
src <- load_library_for_kernel(
  kpath, lib_dir,
  depends_tag = "all_depends_nmath"
)
print(src)
nzchar(src)
}

###############################################################################
## End of load_library_for_kernel example
###############################################################################
