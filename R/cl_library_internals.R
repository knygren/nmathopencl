# Shared helpers for `load_library_for_kernel()` and `extract_library_subset()`.

## Target width for wrapped console output (`message` / `warning` text).
.cl_console_text_width <- function() {
  ow <- as.integer(getOption("width", 80L))
  if (is.na(ow) || ow < 40L)
    ow <- 80L
  min(72L, max(48L, ow))
}


## Greedy wrap of comma-separated identifiers (`name1, name2, ...`) to fit `width`.
.cl_wrap_comma_separated <- function(items, width, first_prefix, cont_prefix) {
  if (!length(items))
    return(character())
  w <- max(20L, as.integer(width)[1L])
  fp <- as.character(first_prefix)[1L]
  cp <- as.character(cont_prefix)[1L]

  lines <- character()
  cur <- paste0(fp, as.character(items[[1L]]))

  if (length(items) == 1L)
    return(cur)

  for (i in 2L:length(items)) {
    nm <- as.character(items[[i]])
    trial <- paste0(cur, ", ", nm)
    if (nchar(trial) > w) {
      lines <- c(lines, cur)
      cur <- paste0(cp, nm)
    } else {
      cur <- trial
    }
  }

  c(lines, cur)
}


## Multi-line `message()` when full bundled `inst/cl/nmath/` is concatenated.
## `display_symbols` holds short names mapped from bundled JSON (`r_wrappers_typical`).
.cl_message_full_nmath_stopgap <- function(display_symbols) {
  lbl <- sort(unique(trimws(as.character(display_symbols))))
  lbl <- lbl[!is.na(lbl) & nzchar(lbl)]
  w <- .cl_console_text_width()
  lines <- if (length(lbl)) {
    paste(
      .cl_wrap_comma_separated(lbl, w, first_prefix = "  ", cont_prefix = "  "),
      collapse = "\n"
    )
  } else {
    ""
  }
  msg <- paste0(
    "Note: full `nmath` library stopgap.\n",
    if (nzchar(lines)) {
      paste0(
        ## Match spirit of fragile-port warnings (base names, no `_opencl` / `.cl`).
        "Symbols prompting this load:\n",
        lines,
        "\n"
      )
    } else {
      ""
    },
    "Using every indexed .cl shard in `library_dir`.\n",
    "See `extdata/opencl_full_nmath_stopgap.json` (assembler parity)."
  )
  message(msg)
}


## Multi-line `warning()` body when annotated stems are absent from the dependency index.
.cl_format_unknown_stems_warning <- function(unknown, depends_tag) {
  unk <- sort(unique(as.character(unknown)))
  w <- .cl_console_text_width()
  tag <- as.character(depends_tag)[1L]
  h1 <- paste0("The following stems from `@", tag, "` were not found in")
  h2 <- "the index and will be skipped:"
  body <- .cl_wrap_comma_separated(unk, w, first_prefix = "  ", cont_prefix = "  ")
  paste(c("", h1, h2, body, ""), collapse = "\n")
}


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
      .cl_format_unknown_stems_warning(unknown, depends_tag),
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
