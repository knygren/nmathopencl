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


## `dpq.cl` / `Rmath.cl` / `nmath.cl` / `refactored.cl` carry huge or internals-style
## `//@provides` lists; `print.nmathopencl_concatenated_lib` summarizes those.
.cl_is_header_style_lib_stem <- function(stem) {
  st <- as.character(stem)[1L]
  nzchar(st) && st %in% c("nmath", "Rmath", "dpq", "refactored")
}


.cl_concat_result <- function(text, stems_requested, stems_loaded,
                              kernel_path, library_dir, depends_tag,
                              nbytes_concatenated) {
  structure(
    text,
    class = c("nmathopencl_concatenated_lib", "character"),
    stems_requested = stems_requested,
    stems_loaded = stems_loaded,
    kernel_path = kernel_path,
    library_dir = library_dir,
    depends_tag = depends_tag,
    nbytes_concatenated = as.integer(nbytes_concatenated)[1]
  )
}


## Parse declaration names bundled with ported NMath `.cl` headers (printing only).
.cl_parse_opencl_kernel_names <- function(path) {
  p <- as.character(path)[1L]
  if (!nzchar(p) || !file.exists(p))
    return(character())

  txt <- paste(readLines(p, warn = FALSE), collapse = " ")
  if (!nzchar(txt) || !grepl("__kernel", txt, fixed = TRUE))
    return(character())

  pat <- "__kernel.*?([A-Za-z_][A-Za-z0-9_]*)\\s*[(]"
  hits <- regmatches(txt, gregexpr(pat, txt, perl = TRUE))[[1L]]
  if (!length(hits))
    return(character())

  out <- character(length(hits))
  for (ii in seq_along(hits)) {
    caps <- tryCatch(
      regmatches(hits[ii], regexec(pat, hits[ii], perl = TRUE)),
      error = function(e) list(character())
    )[[1L]]
    if (length(caps) >= 2L && nzchar(caps[2L]))
      out[ii] <- caps[2L]
  }
  sort(unique(out[nzchar(out)]))
}


.cl_parse_provides_symbols <- function(src_path,
                                       max_probe_lines = 400L) {
  p <- as.character(src_path)[1L]
  nlines <- suppressWarnings(as.integer(max_probe_lines[1]))
  if (is.na(nlines) || nlines < 1L)
    nlines <- 400L
  if (!nzchar(p) || !file.exists(p))
    return(character())

  lines <- readLines(p, n = nlines, warn = FALSE)
  merged <- NA_character_
  for (ln in lines) {
    body <- trimws(gsub("^//\\s*", "", ln))
    if (!nzchar(body))
      next
    if (startsWith(body, "@provides:")) {
      merged <- trimws(sub("^@provides:\\s*", "", body, perl = TRUE))
      break
    }
  }

  mc <- suppressWarnings(as.character(merged))[1]
  if (is.na(mc) || !nzchar(mc))
    return(character())

  tok <- trimws(unlist(strsplit(mc, ",", fixed = TRUE), use.names = FALSE))
  tok <- tok[nzchar(tok)]
  if (!length(tok))
    return(character())
  sort(unique(tok))
}


.cl_print_truncated_symbols <- function(syms, indent,
                                         max_show, label,
                                         start_index = 1L) {
  n <- length(syms)
  if (!n) {
    cat(sprintf("%s(no %ss annotated)\n", indent, label))
    return(invisible(NULL))
  }

  si <- suppressWarnings(as.integer(start_index))[1]
  if (is.na(si))
    si <- 1L

  cap <- suppressWarnings(as.integer(max_show))[1]
  if (is.na(cap) || cap < 1L)
    cap <- length(syms)

  nshow <- min(cap, length(syms))
  for (j in seq_len(nshow)) {
    cat(sprintf("%s %4d. %s\n",
                indent, as.integer(si - 1L + j)[1],
                syms[[j]]))
  }
  if (length(syms) > nshow) {
    rest <- length(syms) - nshow
    cat(sprintf("%s ... and %d more %ss (total %d)\n",
                indent, rest, label, length(syms)))
  }
  invisible(NULL)
}
