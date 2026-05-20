## Full-nmath assembler stopgap (see inst/extdata/opencl_full_nmath_stopgap.json).
## When triggers match and library_dir looks like bundled cl/nmath, subset loaders
## use every stem in kernel_dependency_index.rds rather than annotations alone.


.nmath_opencl_stopgap_json_cache <- new.env(parent = emptyenv())


.cl_read_opencl_full_stopgap_bundle <- function() {
  key <- "__bundle__"
  if (!is.null(.nmath_opencl_stopgap_json_cache[[key]])) {
    return(.nmath_opencl_stopgap_json_cache[[key]])
  }

  json_path <- system.file(
    "extdata", "opencl_full_nmath_stopgap.json",
    package = "nmathopencl"
  )

  out <- NULL
  if (!nzchar(json_path) || !file.exists(json_path)) {
    warning(
      "`opencl_full_nmath_stopgap.json` missing; cannot mirror assembler stopgap rules.",
      call. = FALSE
    )
    .nmath_opencl_stopgap_json_cache[[key]] <- out
    return(out)
  }

  sj <- tryCatch(
    jsonlite::fromJSON(json_path, simplifyVector = TRUE),
    error = function(e) {
      warning("Failed to parse opencl_full_nmath_stopgap.json: ",
              conditionMessage(e),
              call. = FALSE)
      NULL
    }
  )

  if (!is.null(sj$schema_version)) {
    sv <- suppressWarnings(as.integer(sj$schema_version)[1])
    if (!is.na(sv) && sv != 1L) {
      warning(
        "opencl_full_nmath_stopgap.json schema_version is not 1; ",
        "ignored for stopgap routing.",
        call. = FALSE
      )
      sj <- NULL
    }
  }

  .nmath_opencl_stopgap_json_cache[[key]] <- sj
  sj
}


.cl_library_dir_basename_is_nmath <- function(library_dir) {
  lib <- suppressWarnings(
    normalizePath(as.character(library_dir)[1L],
                  winslash = "/", mustWork = FALSE))
  if (!nzchar(lib))
    return(FALSE)
  identical(tolower(basename(lib)), "nmath")
}


## All stems in dependency index sorted by load_order ascending (global order).
.cl_index_stems_all_ordered <- function(index) {
  if (!is.null(index$stems_ordered)) {
    so <- index$stems_ordered
    if (length(so) && is.character(so))
      return(as.character(so))
  }

  lo <- index$load_order
  if (is.null(lo) || !length(lo))
    return(character())

  nm <- names(lo)
  if (is.null(nm) || !length(nm))
    return(character())

  names(sort(lo))
}


## Matching trigger IDs for any launcher in kernel_paths (path suffix or token stems).
.cl_nmath_stopgap_matching_trigger_ids <- function(kernel_paths,
                                                    depends_tag,
                                                    library_dir) {
  ids <- character()
  if (!.cl_library_dir_basename_is_nmath(library_dir))
    return(character())
  if (!identical(as.character(depends_tag)[1L], "all_depends_nmath"))
    return(character())

  bun <- .cl_read_opencl_full_stopgap_bundle()
  if (is.null(bun) || is.null(bun$triggers))
    return(character())

  trg <- bun$triggers
  if (!is.data.frame(trg))
    return(character())

  kpn <- suppressWarnings(normalizePath(
    as.character(kernel_paths), winslash = "/", mustWork = FALSE))

  for (i in seq_len(nrow(trg))) {
    kind <- as.character(trg$detection_kind[[i]])
    idv <- as.character(trg$id[[i]])
    if (!nzchar(kind) || !nzchar(idv))
      next

    if (identical(kind, "launcher_relative_path_suffix")) {
      sfx <- trg$launcher_path_suffix[[i]]
      if (is.na(sfx) || !nzchar(as.character(sfx)))
        next
      sfx <- as.character(sfx)[1L]
      for (kp in kpn) {
        if (!nzchar(kp))
          next
        if (endsWith(kp, sfx))
          ids <- c(ids, idv)
      }
      next
    }

    if (identical(kind, "all_depends_nmath_token")) {
      tok <- trg$token[[i]]
      if (is.na(tok) || !nzchar(as.character(tok)))
        next
      tok <- as.character(tok)[1L]
      for (j in seq_along(kernel_paths)) {
        kp <- as.character(kernel_paths[[j]])[1]
        if (!nzchar(kp))
          next
        lines <- readLines(kp, warn = FALSE)
        need <- parse_port_annotation(lines, depends_tag)
        if (tok %in% need)
          ids <- c(ids, idv)
      }
    }
  }

  unique(ids[!is.na(ids) & nzchar(ids)])
}


## TRUE when expand-to-full-library behavior applies.
.cl_nmath_use_full_library_from_stopgap <- function(trigger_ids) {
  length(trigger_ids) > 0L
}
