############################ Start of load_program_preload example ########################

if (!requireNamespace("opencltools", quietly = TRUE)) {
  stop("Example requires installed opencltools.")
}

manifest <- opencltools::read_program_preload_manifest(source_package = "nmathopencl")
print(manifest)

preload <- opencltools::load_program_preload(source_package = "nmathopencl")
cat("Preload bytes:", attr(preload, "nbytes_concatenated"), "\n")

## End of load_program_preload example
