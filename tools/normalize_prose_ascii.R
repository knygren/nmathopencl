#!/usr/bin/env Rscript
# Replace Unicode punctuation / symbols with ASCII in documentation sources.
# Run from package root: Rscript tools/normalize_prose_ascii.R

.normalize_text_utf8 <- function(x) {
  if (!nzchar(x)) return(x)

  pairs <- matrix(c(
    "\ufeff", "",
    "\u00a0", " ",
    "\u202f", " ",
    "\u2009", " ",
    "\u2002", " ",
    "\u2003", " ",
    "\u3000", " ",
    "\u2028", "\n",

    "\u2014", "---",
    "\u2013", "-",
    "\u2011", "-",
    "\u2212", "-",

    "\u2018", "'",
    "\u2019", "'",
    "\u201a", "'",
    "\u201b", "'",
    "\u2032", "'",

    "\u201c", "\"",
    "\u201d", "\"",
    "\u201e", "\"",
    "\u201f", "\"",
    "\u2033", "\"",

    "\u2026", "...",
    "\u2022", "*",

    "\u2502", "|",

    "\u2192", "->",

    "\u00d7", "x",

    "\u2264", "<=",
    "\u2265", ">="
  ), ncol = 2L, byrow = TRUE)

  for (i in seq_len(nrow(pairs))) {
    x <- gsub(pairs[i, 1L], pairs[i, 2L], x, fixed = TRUE)
  }

  # Do not call iconv(..., "ASCII//TRANSLIT"): on some platforms it mis-handles
  # valid UTF-8 and strips bytes (e.g. smart quotes/em dashes -> "a?'" garbage).
  x
}

root <- normalizePath(".", winslash = "/", mustWork = TRUE)
setwd(root)

paths <- character(0L)
paths <- c(paths, Sys.glob(file.path(root, "vignettes", "*.Rmd")))
paths <- c(paths, Sys.glob(file.path(root, "*.md")))
paths <- c(paths, Sys.glob(file.path(root, "NEWS.md")))
paths <- c(paths, Sys.glob(file.path(root, "cran-comments.md")))
paths <- c(paths, Sys.glob(file.path(root, "CRAN-*")))
desc <- file.path(root, "DESCRIPTION")
if (file.exists(desc)) paths <- c(paths, desc)
paths <- c(paths, list.files(file.path(root, "inst"),
  pattern = "\\.md$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
))

r_extra <- file.path(root, "R", c(
  "gpu_diagnostics.R",
  "load_kernel_library.R",
  "internal_rcppparallel.R",
  "rcpp_wrappers.R",
  "cl_library_utils.R"
))
paths <- c(paths, r_extra[file.exists(r_extra)])

paths <- unique(paths[file.exists(paths)])
paths <- normalizePath(paths, winslash = "/", mustWork = TRUE)

n_up <- 0L
for (f in paths) {
  ln <- tryCatch(readLines(f, encoding = "UTF-8", warn = FALSE), error = function(e) NA)
  if (anyNA(ln)) next
  orig <- paste0(ln, collapse = "\n")
  nw <- .normalize_text_utf8(orig)
  if (!identical(nw, orig)) {
    writeLines(strsplit(nw, "\n", fixed = TRUE)[[1L]], con = f, useBytes = FALSE)
    message("normalized: ", f)
    n_up <- n_up + 1L
  }
}

message(sprintf("Done. %d file(s) changed.", as.integer(n_up)))
