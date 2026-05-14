#' Load a Minimal OpenCL Library Subset for a Single Kernel
#'
#' Given a single kernel `.cl` file and a library directory (with an associated
#' dependency index), reads the annotation tag that lists needed library files
#' and returns their source code concatenated in the correct dependency order.
#'
#' It is strongly recommended to supply a pre-loaded `index` rather than
#' letting the function read it from disk on every call.  Load the index once
#' and reuse it across all kernel calls:
#'
#' ```r
#' idx <- readRDS(system.file("cl", "nmath", "kernel_dependency_index.rds",
#'                            package = "nmathopencl"))
#' src <- load_library_for_kernel(kernel_path, nmath_dir, index = idx)
#' ```
#'
#' @param kernel_path Path to a single `.cl` kernel file.  The file is scanned
#'   for the annotation tag given by `depends_tag`.
#' @param library_dir Path to the library directory containing the `.cl` source
#'   files (e.g. `system.file("cl", "nmath", package = "nmathopencl")`).
#' @param depends_tag Name of the annotation tag in the kernel file that lists
#'   the required library file stems.  Defaults to `"all_depends"`.  For
#'   kernels annotated with `@all_depends_nmath`, pass
#'   `depends_tag = "all_depends_nmath"`.
#' @param index Pre-loaded dependency index (`list`) produced by
#'   [write_kernel_dependency_index()] and read with [readRDS()].  If `NULL`,
#'   the index is read from
#'   `file.path(library_dir, "kernel_dependency_index.rds")` and a `message()`
#'   is emitted to encourage the recommended pattern.
#'
#' @return A single character string: the concatenated source of all required
#'   library files in dependency order, separated by a blank line.  Returns
#'   `""` invisibly when the kernel file carries no `@{depends_tag}`
#'   annotation, so it can be safely passed to `paste()` or included in a
#'   larger program assembly without special-casing.
#'
#' @seealso [extract_library_subset()], [write_kernel_dependency_index()]
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


#' Extract a Minimal Library Subset for a Set of Kernels
#'
#' Given one or more kernel `.cl` files and a library directory, determines the
#' minimal set of library files required (union of all kernels' dependency
#' annotations) and copies them — in dependency order — to a destination
#' directory.
#'
#' Use this to populate a project-local copy containing only the library files
#' actually needed by your kernels.  The result can then be committed alongside
#' your kernel files, removing a runtime dependency on the full library.
#'
#' It is strongly recommended to supply a pre-loaded `index`:
#'
#' ```r
#' idx <- readRDS(system.file("cl", "nmath", "kernel_dependency_index.rds",
#'                            package = "nmathopencl"))
#' result <- extract_library_subset(kernel_paths, nmath_dir, dest_dir,
#'                                  index = idx)
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
#'   are not overwritten — the copy is skipped and `copied = FALSE` in the
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
#' @seealso [load_library_for_kernel()], [write_kernel_dependency_index()]
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

  # Always copy the dependency index alongside the .cl files so the extracted
  # subset is immediately usable with the recommended pre-loaded index pattern.
  rds_name <- "kernel_dependency_index.rds"
  rds_src  <- file.path(library_dir, rds_name)
  rds_dst  <- file.path(dest_dir,    rds_name)
  rds_row  <- if (file.exists(rds_src)) {
    do_copy <- isTRUE(overwrite) || !file.exists(rds_dst)
    if (do_copy) {
      file.copy(rds_src, rds_dst, overwrite = overwrite)
    }
    data.frame(stem = rds_name, source = rds_src, dest = rds_dst,
               copied = do_copy, stringsAsFactors = FALSE)
  } else {
    warning("No `kernel_dependency_index.rds` found in `library_dir`; ",
            "index was not copied. Run `write_kernel_dependency_index()` to create it.",
            call. = FALSE)
    NULL
  }

  result <- do.call(rbind, result_rows)
  if (!is.null(rds_row)) {
    result <- rbind(result, rds_row)
  }
  invisible(result)
}


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

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
