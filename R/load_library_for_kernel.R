#' Load a Minimal OpenCL Library Subset for a Single Kernel
#'
#' Given a single kernel `.cl` file and a library directory (with an associated
#' dependency index), reads the annotation tag that lists needed library files
#' and returns their source code concatenated in the correct dependency order.
#'
#' It is strongly recommended to supply a pre-loaded `index` rather than
#' letting the function read from disk on every call.  Load the index once
#' and reuse it across all kernel calls:
#'
#' ```r
#' lib_dir <- system.file("cl/ex_glmbayes_nmath", package = "nmathopencl")
#' idx <- write_kernel_dependency_index(library_dir = lib_dir, write = FALSE)
#' src <- load_library_for_kernel(
#'   kernel_path, lib_dir, depends_tag = "all_depends_nmath", index = idx)
#' ```
#'
#' @param kernel_path Path to a single `.cl` kernel file.  The file is scanned
#'   for the annotation tag given by `depends_tag`.
#' @param library_dir Path to the library directory containing the `.cl` source
#'   files (e.g. `system.file("cl/nmath", package = "nmathopencl")`).
#' @param depends_tag Name of the annotation tag in the kernel file that lists
#'   the required library file stems.  Defaults to `"all_depends"`.  For
#'   kernels annotated with `@all_depends_nmath`, pass
#'   `depends_tag = "all_depends_nmath"`.
#' @param index Optional RDS list; \code{NULL} triggers lazy reads.
#'
#' @return A single character string: the concatenated source of all required
#'   library files in dependency order, separated by a blank line.  Returns
#'   `""` invisibly when the kernel file carries no `@{depends_tag}`
#'   annotation, so it can be safely passed to `paste()` or included in a
#'   larger program assembly without special-casing.
#'
#' @seealso [extract_library_subset()]
#' @seealso [write_kernel_dependency_index()]
#' @family OpenCL kernel library subsets
#'
#' @example inst/examples/Ex_load_library_for_kernel.R
#'
#' @export
load_library_for_kernel <- function(kernel_path,
                                    library_dir,
                                    depends_tag = "all_depends",
                                    index = NULL) {
  if (!file.exists(kernel_path)) {
    stop("`kernel_path` does not exist: ", kernel_path, call. = FALSE)
  }
  if (!dir.exists(library_dir)) {
    stop("`library_dir` does not exist: ", library_dir, call. = FALSE)
  }

  index <- .cl_load_index(index, library_dir)

  lines  <- readLines(kernel_path, warn = FALSE)
  needed <- parse_port_annotation(lines, depends_tag)

  if (length(needed) == 0L) {
    return(invisible(""))
  }

  stems_to_load <- .cl_filter_stems(needed, index, depends_tag)
  if (length(stems_to_load) == 0L) {
    return(invisible(""))
  }

  stems_to_load <- stems_to_load[order(index$load_order[stems_to_load])]

  parts <- vapply(stems_to_load, function(stem) {
    path <- file.path(library_dir, paste0(stem, ".cl"))
    if (!file.exists(path)) {
      warning("Library file not found for stem '", stem, "': ", path,
              call. = FALSE)
      return("")
    }
    paste(readLines(path, warn = FALSE), collapse = "\n")
  }, character(1L))

  paste(parts[nzchar(parts)], collapse = "\n\n")
}
