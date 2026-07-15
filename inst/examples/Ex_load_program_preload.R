############################ Start of load_program_preload example ########################

if (!requireNamespace("opencltools", quietly = TRUE)) {
  stop("Example requires installed opencltools.")
}

manifest <- opencltools::read_program_preload_manifest(source_package = "nmathopencl")
print(manifest)

preload <- opencltools::load_program_preload(source_package = "nmathopencl")
cat("Preload bytes:", attr(preload, "nbytes_concatenated"), "\n")

\donttest{
## Full program assembly: prelude + nmath subset + launcher kernel.
## When the launcher lives in another installed package, use
## load_library_for_kernel_cross_package(..., kernel_package = "yourpkg",
## library_package = "nmathopencl") and load_kernel_source(..., package = "yourpkg").

kernel_rel <- "src/dnorm_kernel.cl"

nmath_src <- opencltools::load_library_for_kernel(
  system.file("cl", kernel_rel, package = "nmathopencl"),
  system.file("cl/nmath", package = "nmathopencl"),
  depends_tag = "all_depends_nmath"
)

ksrc <- opencltools::load_kernel_source(kernel_rel, package = "nmathopencl")

program <- paste(preload, nmath_src, ksrc, sep = "\n")
cat("Full program bytes:", nchar(program, type = "bytes"), "\n")
}

## End of load_program_preload example
