# Shared helpers for `load_library_for_kernel()` and `extract_library_subset()`.

.cl_load_index <- function(index, library_dir) {
  if (!is.null(index)) {
    return(index)
  }
  idx_path <- file.path(library_dir, "kernel_dependency_index.rds")
  if (!file.exists(idx_path)) {
    stop(
      "No `kernel_dependency_index.rds` found in `library_dir` (", library_dir,
      "). Run `write_kernel_dependency_index()` first, or supply `index =`.",
      call. = FALSE
    )
  }
  message(
    "No `index` supplied; reading kernel_dependency_index.rds from disk. ",
    "For better performance, load the index once and pass it via `index =`."
  )
  readRDS(idx_path)
}


.cl_filter_stems <- function(needed, index, depends_tag) {
  known   <- names(index$load_order)
  unknown <- setdiff(needed, known)
  if (length(unknown) > 0L) {
    warning(
      "The following stems from @", depends_tag,
      " were not found in the index and will be skipped: ",
      paste(unknown, collapse = ", "),
      call. = FALSE
    )
  }
  intersect(needed, known)
}
