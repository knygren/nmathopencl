## Known fragile / unported nmath subgraphs tracked in opencl_known_failures.json.


.nmath_known_failures_json_cache <- new.env(parent = emptyenv())


.cl_read_opencl_known_failures_bundle <- function() {
  key <- "__bundle__"
  if (!is.null(.nmath_known_failures_json_cache[[key]]))
    return(.nmath_known_failures_json_cache[[key]])

  json_path <- system.file("extdata", "opencl_known_failures.json",
                           package = "nmathopencl")
  out <- NULL
  if (!nzchar(json_path) || !file.exists(json_path)) {
    .nmath_known_failures_json_cache[[key]] <- out
    warning("`opencl_known_failures.json` missing; skipping known-failure hints.",
            call. = FALSE)
    return(out)
  }

  sj <- tryCatch(
    jsonlite::fromJSON(json_path, simplifyVector = TRUE),
    error = function(e) {
      warning("Failed to parse opencl_known_failures.json: ",
              conditionMessage(e),
              call. = FALSE)
      NULL
    }
  )

  if (!is.null(sj) && !is.null(sj$schema_version)) {
    sv <- suppressWarnings(as.integer(sj$schema_version)[1])
    if (!is.na(sv) && sv != 1L) {
      warning(
        "opencl_known_failures.json schema_version is not 1; ignored.",
        call. = FALSE
      )
      sj <- NULL
    }
  }

  .nmath_known_failures_json_cache[[key]] <- sj
  sj
}


## Character vector helpers: trim whitespace, drop NA/empty unique.
.cl_stem_normalize_set <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x[!is.na(x) & nzchar(x)]
}


## Rows of entries as a list-of-lists (robust vs jsonlite list vs DF).
.cl_known_failure_entries_ll <- function(sj) {
  if (is.null(sj) || is.null(sj$entries))
    return(list())

  ej <- sj$entries
  if (is.data.frame(ej)) {
    lapply(seq_len(nrow(ej)), function(i) as.list(ej[i, ]))
  } else if (is.list(ej)) {
    ej
  } else {
    list()
  }
}


## Basenames of launcher .cl paths under each entry (e.g. "qbeta_kernel.cl").
.cl_known_failure_launcher_basenames <- function(entry) {
  rel <- entry$entry_kernels_package_relative
  if (is.null(rel))
    return(character())
  rel <- trimws(as.character(unlist(rel, use.names = FALSE)))
  rel <- rel[!is.na(rel) & nzchar(rel)]
  basename(rel)
}


## Matches when any kernel_paths basename equals a catalogued entry launcher stem.
.cl_known_failure_launcher_hit <- function(kernel_paths_norm, entry) {
  if (!length(kernel_paths_norm))
    return(FALSE)
  want <- .cl_known_failure_launcher_basenames(entry)
  if (!length(want))
    return(FALSE)
  any(basename(kernel_paths_norm) %in% want, na.rm = TRUE)
}


.cl_known_failure_annotate_hit <- function(annotated_stems, entry) {
  ns <- entry$nmath_stems
  if (is.null(ns))
    ns <- character()
  ns <- .cl_stem_normalize_set(as.character(unlist(ns, use.names = FALSE)))
  if (!length(ns) || !length(annotated_stems))
    return(FALSE)
  length(intersect(.cl_stem_normalize_set(annotated_stems), ns)) > 0L
}


.cl_known_failure_loaded_hit <- function(stems_loaded, entry) {
  if (is.null(stems_loaded) || !length(stems_loaded))
    return(FALSE)
  ns <- entry$nmath_stems
  if (is.null(ns))
    ns <- character()
  ns <- .cl_stem_normalize_set(as.character(unlist(ns, use.names = FALSE)))
  if (!length(ns))
    return(FALSE)
  sl <- .cl_stem_normalize_set(as.character(stems_loaded))
  length(intersect(sl, ns)) > 0L
}


## Optionally warn once per subset-load call (see docs on extract vs loader).
.cl_maybe_warn_opencl_known_failures <- function(kernel_paths_norm,
                                                 annotated_stems,
                                                 stems_loaded_optional = NULL,
                                                 warn_on_loaded_mesh = TRUE) {
  sj <- .cl_read_opencl_known_failures_bundle()
  if (is.null(sj))
    return(invisible())

  ents <- .cl_known_failure_entries_ll(sj)
  matched_wrappers <- character()

  kp <- suppressWarnings(normalizePath(
    as.character(kernel_paths_norm),
    winslash = "/", mustWork = FALSE))

  ann <- .cl_stem_normalize_set(as.character(annotated_stems))

  for (e in ents) {
    lh <- .cl_known_failure_launcher_hit(kp, e)
    ah <- .cl_known_failure_annotate_hit(ann, e)
    sh <- warn_on_loaded_mesh &&
      .cl_known_failure_loaded_hit(stems_loaded_optional, e)

    if (lh || ah || sh) {
      rw <- e$r_wrappers
      rw <- .cl_stem_normalize_set(as.character(unlist(rw, use.names = FALSE)))
      matched_wrappers <- c(matched_wrappers, rw)
    }
  }

  matched_wrappers <- sort(unique(matched_wrappers))

  if (length(matched_wrappers)) {
    warning(
      "Calls to unported nmath function(s) found: ",
      paste(matched_wrappers, collapse = ", "),
      ". Retain calls to CPU-based versions for these functions ",
      "and revise kernels.",
      call. = FALSE
    )
  }

  invisible()
}
