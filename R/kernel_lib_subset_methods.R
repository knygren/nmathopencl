#' Printing results from minimal kernel-library subset loaders
#'
#' \link{load_library_for_kernel} returns a concatenated OpenCL-sources string
#' with classes \verb{nmathopencl_concatenated_lib}, subclassing \code{character},
#' with attributes listing requested and loaded stems in dependency order.
#'
#' \link{extract_library_subset} returns classes \verb{nmathopencl_lib_extract_df},
#' subclassing \code{data.frame}, with paths and tag metadata attached.
#'
#' @param x From \link{load_library_for_kernel} or \link{extract_library_subset}.
#' @param ... For the extract data frame printer: forwarded to \code{print.data.frame}
#'   when previewing rows.
#' @param max_df_rows Number of preview rows (\code{head}) after stem listing (default \code{6}).
#'
#' @name kernel_lib_subset_printing


#' @rdname kernel_lib_subset_printing
#' @export
print.nmathopencl_concatenated_lib <- function(x, ...) {
  stems_req <- attr(x, "stems_requested", exact = TRUE)
  stems_ld <- attr(x, "stems_loaded", exact = TRUE)
  kpath <- attr(x, "kernel_path", exact = TRUE)
  lib_dir <- attr(x, "library_dir", exact = TRUE)
  tag <- attr(x, "depends_tag", exact = TRUE)

  sr <- if (length(stems_req)) stems_req else character()
  sl <- if (length(stems_ld)) stems_ld else character()

  cat("<nmathopencl_concatenated_lib>\n")

  kp <- suppressWarnings(normalizePath(
    if (is.null(kpath)) NA_character_ else as.character(kpath),
    winslash = "/", mustWork = FALSE
  ))
  ld <- suppressWarnings(normalizePath(
    if (is.null(lib_dir)) NA_character_ else as.character(lib_dir),
    winslash = "/", mustWork = FALSE
  ))

  if (!is.na(kp)) cat("Kernel:", kp, fill = TRUE)
  if (!is.na(ld)) cat("Library directory:", ld, fill = TRUE)

  tc <- if (!is.null(tag)) as.character(tag[1L]) else NA_character_
  cat("Depends tag:",
      ifelse(!is.na(tc) && nzchar(tc), tc, "all_depends"),
      fill = TRUE)

  cat("\nRequested library stems (dependency order,", length(sr), ", files):\n", sep = "")
  .cl_print_stems_numbered(sr)

  missed <- setdiff(sr, sl)
  if (length(missed)) {
    cat("\nStems omitted (missing `.cl` in `library_dir`):\n")
    .cl_print_stems_numbered(missed)
  }

  cat("\nStems concatenated into the returned string (dependency order,",
      length(sl), "):\n", sep = "")
  .cl_print_stems_numbered(sl)

  merged <- paste(as.character(unclass(x)), collapse = "\n\n")
  nbytes_obs <- if (nzchar(merged)) {
    nchar(enc2utf8(merged), type = "bytes")
  } else {
    0L
  }
  nm <- attr(x, "nbytes_concatenated", exact = TRUE)
  nbytes_show <- if (!is.null(nm) && length(nm) && !is.na(nm[1])) {
    as.integer(nm[1])[1]
  } else {
    nbytes_obs
  }
  cat("\nConcatenated source size (bytes, UTF-8 where applicable): ",
      nbytes_show, sep = "")
  cat("\n\n(character vector: substr(), paste(), writeLines(), ...)\n", sep = "")
  invisible(x)
}


#' @rdname kernel_lib_subset_printing
#' @export
print.nmathopencl_lib_extract_df <- function(x, ..., max_df_rows = 6L) {
  kpaths <- attr(x, "kernel_paths", exact = TRUE)
  lib_dir <- attr(x, "library_dir", exact = TRUE)
  dest_dir <- attr(x, "dest_dir", exact = TRUE)
  tag <- attr(x, "depends_tag", exact = TRUE)

  cat("<nmathopencl_lib_extract_df>\n")

  nk <- ifelse(!is.null(kpaths), length(as.character(kpaths)), 0L)
  tc <- ifelse(!is.null(tag), as.character(tag[1L]), NA_character_)

  cat("Depends tag:",
      ifelse(!is.na(tc) && nzchar(tc), tc, "all_depends"),
      fill = TRUE)

  cat("Extracted subset rows:", nrow(x), fill = TRUE)

  if (!is.na(lib_dir) && nzchar(as.character(lib_dir))) {
    cat("Library:",
        suppressWarnings(normalizePath(as.character(lib_dir)[1],
                                       winslash = "/", mustWork = FALSE)),
        fill = TRUE)
  }
  if (!is.na(dest_dir) && nzchar(as.character(dest_dir))) {
    cat("Destination:",
        suppressWarnings(normalizePath(as.character(dest_dir)[1],
                                       winslash = "/", mustWork = FALSE)),
        fill = TRUE)
  }

  if (!is.null(kpaths) && length(as.character(kpaths))) {
    kp <- suppressWarnings(normalizePath(as.character(kpaths),
                                         winslash = "/", mustWork = FALSE))
    cat("Kernel .cl paths (", nk, "):\n", sep = "")
    cat(paste(sprintf(" %2d. %s", seq_along(kp), kp), collapse = "\n"), sep = "", fill = TRUE)
    cat(fill = TRUE)
  }

  is_idx <- x$stem %in% c("kernel_dependency_index.rds", "kernel_dependency_index.tsv")
  lib_ix <- seq_len(nrow(x))[!is_idx]
  ix_ix <- seq_len(nrow(x))[ is_idx]

  cat("Library stems copied (.cl dependency order):", length(lib_ix), fill = TRUE)
  for (jn in seq_along(lib_ix)) {
    r <- lib_ix[jn]
    ds <- ifelse(!is.na(x$dest[r]), basename(as.character(x$dest[r])), "?")
    fl <- ifelse(isTRUE(as.logical(x$copied[r])), "copied", "skipped(existing)")
    cat(sprintf(" %3d. %-30s %-12s [%s]\n", jn, paste0(as.character(x$stem[r]), ".cl"),
                fl, ds))
  }
  if (!length(lib_ix))
    cat("  (none)\n")

  if (length(ix_ix)) {
    aux <- paste(as.character(unique(x$stem[ix_ix])), collapse = ", ")
    cat("\nIndex helpers:", aux, fill = TRUE)
  }

  md <- suppressWarnings(utils::head(x, max_df_rows))
  cat("\nData frame preview (first", min(max_df_rows, nrow(x)),
      "rows of ", nrow(x), "):\n", sep = "")
  print.data.frame(md, ...)
  invisible(x)
}


#' @keywords internal
.cl_print_stems_numbered <- function(stems_vec) {
  if (!length(stems_vec)) {
    cat("  (none)\n")
    return(invisible(NULL))
  }
  for (jj in seq_along(stems_vec)) {
    s <- as.character(stems_vec[[jj]])
    suf <- ifelse(nzchar(s), paste0(s, ".cl"), "(empty stem)")
    cat(sprintf(" %3d. %s\n", jj, suf))
  }
  invisible(NULL)
}


#' Attach class/metadata to extraction `data.frame` (internal helper).
#'
#' @noRd
.cl_attach_extract_attrs <- function(df, kernel_paths, library_dir,
                                     dest_dir, depends_tag) {
  attr(df, "kernel_paths") <- as.character(kernel_paths)
  attr(df, "library_dir") <- as.character(library_dir)[1]
  attr(df, "dest_dir") <- as.character(dest_dir)[1]
  attr(df, "depends_tag") <- as.character(depends_tag)[1]
  class(df) <- c("nmathopencl_lib_extract_df", "data.frame")
  invisible(df)
}
