#' Build and save a kernel dependency index (RDS)
#'
#' Writes `kernel_dependency_index.rds` next to the `.cl` files in the kernel
#' library directory. The index matches the dependency sort used by
#' [attach_kernel_dependency_tags()] and is intended for fast runtime assembly
#' of minimal source bundles using roots + transitive `@all_depends`.
#'
#' @param library_dir Directory containing `.cl` files with `@depends` tags.
#'   Required when `tags` is `NULL`. When `tags` is non-NULL, optional; if given,
#'   it must equal `tags$library_dir` after normalization.
#' @param tags Optional result of [attach_kernel_dependency_tags()]. When
#'   non-NULL and `tags$ok` is `TRUE`, reused to avoid recomputing the dependency
#'   sort.
#' @param output_path Path for the RDS file. Defaults to
#'   `file.path(<library_dir>, "kernel_dependency_index.rds")`.
#' @param write If `FALSE`, builds the index object and returns it without writing.
#' @param verbose If `TRUE`, emits a short message with the output path.
#'
#' @return Invisibly, the index `list()` written to RDS (`version` schema):
#'   - `version`: integer schema version.
#'   - `generated_at`: timestamp from [Sys.time()].
#'   - `library_dir`, `library_name`: resolved library path / basename.
#'   - `stems_ordered`: stems in global load order.
#'   - `load_order`: named integer vector `stem -> rank`.
#'   - `depends`: named list `stem -> character()` (direct `@depends`).
#'   - `all_depends`: named list `stem -> character()` (transitive deps, order
#'     consistent with global load order).
#'   - `n_files`: file count.
#'
#' @export
write_kernel_dependency_index <- function(
    library_dir = NULL,
    tags = NULL,
    output_path = NULL,
    write = TRUE,
    verbose = FALSE) {
  if (is.null(tags)) {
    if (is.null(library_dir) || !nzchar(as.character(library_dir)[1L])) {
      stop("`library_dir` is required when `tags` is NULL.", call. = FALSE)
    }
    if (!dir.exists(library_dir)) {
      stop("`library_dir` does not exist: ", library_dir, call. = FALSE)
    }
    tags <- attach_kernel_dependency_tags(library_dir, dry_run = TRUE)
    if (!isTRUE(tags$ok)) {
      stop(tags$message, call. = FALSE)
    }
  } else {
    if (!isTRUE(tags$ok)) {
      stop(
        "`tags` has ok=FALSE; resolve dependency sorting before building index.",
        call. = FALSE
      )
    }
    lt <- tags$library_dir
    if (is.null(lt) || !nzchar(as.character(lt)[1L]) || !dir.exists(lt)) {
      stop("`tags$library_dir` must be a valid existing directory.", call. = FALSE)
    }
    if (!is.null(library_dir) && nzchar(as.character(library_dir)[1L])) {
      a <- normalizePath(library_dir, winslash = "/", mustWork = FALSE)
      b <- normalizePath(lt, winslash = "/", mustWork = FALSE)
      if (!identical(tolower(a), tolower(b))) {
        stop(
          "`library_dir` does not match `tags$library_dir`.",
          call. = FALSE
        )
      }
    }
  }

  lib_dir <- normalizePath(tags$library_dir, winslash = "/", mustWork = TRUE)
  idx <- kernel_dependency_index_list_from_tags(tags, lib_dir_resolved = lib_dir)

  out_default <- file.path(lib_dir, "kernel_dependency_index.rds")
  out <- if (is.null(output_path)) out_default else output_path

  out_dir <- normalizePath(dirname(out), winslash = "/", mustWork = TRUE)
  out_final <- file.path(out_dir, basename(out))

  if (!is.logical(write) || length(write) != 1L || is.na(write)) {
    stop("`write` must be a single logical value.", call. = FALSE)
  }
  if (isTRUE(write)) {
    saveRDS(idx, file = out_final, compress = TRUE)
    if (isTRUE(verbose)) {
      message("Wrote kernel dependency index: ", out_final)
    }
  }
  invisible(idx)
}


kernel_dependency_index_list_from_tags <- function(tags, lib_dir_resolved = NULL) {
  td <- tags$tags
  if (!is.data.frame(td) || nrow(td) == 0L) {
    stop("`tags$tags` must be a non-empty data frame.", call. = FALSE)
  }

  abs_lib <- if (!is.null(lib_dir_resolved)) {
    lib_dir_resolved
  } else {
    normalizePath(tags$library_dir, winslash = "/", mustWork = TRUE)
  }

  stems_ordered <- td$file[order(td$load_order, td$file)]
  load_order_named <- stats::setNames(as.integer(td$load_order), td$file)

  n <- nrow(td)
  depends_list <- vector("list", n)
  names(depends_list) <- td$file
  all_depends_list <- vector("list", n)
  names(all_depends_list) <- td$file

  for (i in seq_len(n)) {
    stem <- td$file[[i]]
    depends_list[[stem]] <- split_kernel_depends_csv_char(td$depends[[i]])
    all_depends_list[[stem]] <- split_kernel_depends_csv_char(td$all_depends[[i]])
  }

  list(
    version = 1L,
    generated_at = Sys.time(),
    library_dir = abs_lib,
    library_name = basename(abs_lib),
    stems_ordered = stems_ordered,
    load_order = load_order_named,
    depends = depends_list,
    all_depends = all_depends_list,
    n_files = n
  )
}


split_kernel_depends_csv_char <- function(x) {
  if (length(x) != 1L) {
    x <- as.character(x)
    x <- x[[1]]
  }
  if (is.na(x) || !nzchar(x)) {
    return(character())
  }
  parts <- trimws(strsplit(as.character(x), ",", fixed = TRUE)[[1]], which = "both")
  parts[nzchar(parts)]
}
