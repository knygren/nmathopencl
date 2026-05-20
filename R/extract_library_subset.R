#' Extract a Minimal Library Subset for a Set of Kernels
#'
#' Given one or more kernel `.cl` files and a library directory, determines the
#' minimal set of library files required (union of all kernels' dependency
#' annotations) and copies them --- in dependency order --- to a destination
#' directory.
#'
#' Use this to populate a project-local copy containing only the library files
#' actually needed by your kernels.  The result can then be committed alongside
#' your kernel files, removing a runtime dependency on the full library.
#'
#' It is strongly recommended to supply a pre-loaded `index`:
#'
#' ```r
#' lib_dir <- system.file("cl/ex_glmbayes_nmath", package = "nmathopencl")
#' idx <- write_kernel_dependency_index(library_dir = lib_dir, write = FALSE)
#' result <- extract_library_subset(
#'   kernel_paths, lib_dir, dest_dir,
#'   depends_tag = "all_depends_nmath", index = idx)
#' ```
#'
#' @param kernel_paths Character vector of paths to kernel `.cl` files.  Each
#'   file is scanned for the annotation tag given by `depends_tag`.
#' @param library_dir Path to the source library directory.
#' @param dest_dir Path to the destination directory.  Must already exist; a
#'   warning is issued and the function returns invisibly if it does not.
#'   In addition to the `.cl` files, `kernel_dependency_index.rds` is copied
#'   here so the extracted subset can be used immediately with a pre-loaded
#'   index.
#' @param depends_tag Name of the annotation tag listing library file stems.
#'   Defaults to `"all_depends"`.  Pass `"all_depends_nmath"` for kernels that
#'   annotate their nmath dependencies with that tag.
#' @param index Pre-loaded dependency index.  If `NULL`, read from
#'   `file.path(library_dir, "kernel_dependency_index.rds")` with a
#'   `message()` nudging toward the recommended pattern.
#' @param overwrite Logical; if `FALSE` (default) existing files in `dest_dir`
#'   are not overwritten --- the copy is skipped and `copied = FALSE` in the
#'   returned data frame.
#'
#' @return A data frame (returned invisibly) with one row per copied file
#'   (`.cl` files in dependency order, followed by
#'   `kernel_dependency_index.rds`) and columns:
#'   \describe{
#'     \item{`stem`}{Stem name (filename without `.cl`), or
#'       `"kernel_dependency_index.rds"` for the index.}
#'     \item{`source`}{Full path to the source file in `library_dir`.}
#'     \item{`dest`}{Full path to the destination file in `dest_dir`.}
#'     \item{`copied`}{`TRUE` if the file was copied; `FALSE` if it already
#'       existed and `overwrite = FALSE`.}
#'   }
#'
#' @seealso [load_library_for_kernel()]
#' @seealso [write_kernel_dependency_index()]
#' @family OpenCL kernel library subsets
#'
#' @example inst/examples/Ex_extract_library_subset.R
#'
#' @export
extract_library_subset <- function(kernel_paths,
                                   library_dir,
                                   dest_dir,
                                   depends_tag = "all_depends",
                                   index = NULL,
                                   overwrite = FALSE) {
  empty_df <- function() {
    data.frame(stem = character(), source = character(),
               dest = character(), copied = logical(),
               stringsAsFactors = FALSE)
  }

  if (!dir.exists(library_dir)) {
    stop("`library_dir` does not exist: ", library_dir, call. = FALSE)
  }
  if (!dir.exists(dest_dir)) {
    warning("`dest_dir` does not exist: ", dest_dir,
            ". No files were copied.", call. = FALSE)
    return(invisible(empty_df()))
  }

  missing_kernels <- kernel_paths[!file.exists(kernel_paths)]
  if (length(missing_kernels) > 0L) {
    stop("The following `kernel_paths` do not exist:\n",
         paste(" ", missing_kernels, collapse = "\n"), call. = FALSE)
  }

  index <- .cl_load_index(index, library_dir)

  all_needed <- character()
  for (kpath in kernel_paths) {
    lines <- readLines(kpath, warn = FALSE)
    stems <- parse_port_annotation(lines, depends_tag)
    all_needed <- union(all_needed, stems)
  }

  if (length(all_needed) == 0L) {
    message("No `@", depends_tag, "` annotations found in any kernel file. ",
            "Nothing to copy.")
    return(invisible(empty_df()))
  }

  stems_to_copy <- .cl_filter_stems(all_needed, index, depends_tag)
  if (length(stems_to_copy) == 0L) {
    return(invisible(empty_df()))
  }

  stems_to_copy <- stems_to_copy[order(index$load_order[stems_to_copy])]

  result_rows <- lapply(stems_to_copy, function(stem) {
    src <- file.path(library_dir, paste0(stem, ".cl"))
    dst <- file.path(dest_dir,    paste0(stem, ".cl"))

    if (!file.exists(src)) {
      warning("Source file not found for stem '", stem, "': ", src,
              call. = FALSE)
      return(data.frame(stem = stem, source = src, dest = dst,
                        copied = FALSE, stringsAsFactors = FALSE))
    }

    do_copy <- isTRUE(overwrite) || !file.exists(dst)
    if (do_copy) {
      file.copy(src, dst, overwrite = overwrite)
    }
    data.frame(stem = stem, source = src, dest = dst,
               copied = do_copy, stringsAsFactors = FALSE)
  })

  index_files <- c("kernel_dependency_index.rds", "kernel_dependency_index.tsv")
  index_rows <- lapply(index_files, function(idx_name) {
    src <- file.path(library_dir, idx_name)
    dst <- file.path(dest_dir,    idx_name)
    if (!file.exists(src)) {
      warning("No `", idx_name, "` found in `library_dir`; not copied. ",
              "Run `write_kernel_dependency_index()` to create it.",
              call. = FALSE)
      return(NULL)
    }
    do_copy <- isTRUE(overwrite) || !file.exists(dst)
    if (do_copy) {
      file.copy(src, dst, overwrite = overwrite)
    }
    data.frame(stem = idx_name, source = src, dest = dst,
               copied = do_copy, stringsAsFactors = FALSE)
  })

  result <- do.call(rbind, c(result_rows, Filter(Negate(is.null), index_rows)))
  invisible(result)
}
