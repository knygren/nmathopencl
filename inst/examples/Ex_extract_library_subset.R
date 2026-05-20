############################ Start of extract_library_subset example #########################

\donttest{
lib_dir <- system.file("cl/ex_glmbayes_nmath", package = "nmathopencl")
kpath <- system.file(
  "cl/ex_glmbayes_src/f2_f3_gaussian.cl",
  package = "nmathopencl"
)
idx <- write_kernel_dependency_index(library_dir = lib_dir, write = FALSE)
dest_dir <- tempfile("exglmbsubset")
dir.create(dest_dir)
on.exit(unlink(dest_dir, recursive = TRUE), add = TRUE)
df <- extract_library_subset(
  kpath, lib_dir, dest_dir,
  depends_tag = "all_depends_nmath",
  index = idx
)
print(df)
sum(df$copied)
}

###############################################################################
## End of extract_library_subset example
###############################################################################
