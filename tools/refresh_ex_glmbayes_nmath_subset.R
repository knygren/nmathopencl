pkg_dir <- normalizePath("C:/Rpackages/nmathopencl", winslash = "/", mustWork = TRUE)
pkgload::load_all(pkg_dir, quiet = TRUE, compile = FALSE)

nmath_dir <- file.path(pkg_dir, "inst/cl/nmath")
src_dir   <- file.path(pkg_dir, "inst/cl/ex_glmbayes_src")
dest_dir  <- file.path(pkg_dir, "inst/cl/ex_glmbayes_nmath")

kern <- sort(list.files(src_dir, pattern = "\\.cl$", full.names = TRUE))
idx <- readRDS(file.path(nmath_dir, "kernel_dependency_index.rds"))

message("attach_cross_library_tags() …")
attach_cross_library_tags(
  kernel_paths = kern,
  library_dir = nmath_dir,
  depends_tag = "depends_nmath",
  index = idx,
  dry_run = FALSE
)

message("extract_library_subset() …")
subs <- extract_library_subset(
  kernel_paths = kern,
  library_dir = nmath_dir,
  dest_dir = dest_dir,
  depends_tag = "all_depends_nmath",
  index = idx,
  overwrite = TRUE
)
message("Copied / refreshed stems: ", nrow(subs))
print(subs[, c("stem", "copied")], row.names = FALSE)
message("done.")
