# Invoked by configure / configure.win. Prints a single -I"path" line to stdout (Rcpp include dir).
# Messages and warnings go to stderr.
#
# GLMBAYES_RCPP_LIB — optional: explicit library directory that contains Rcpp/ (e.g. CI user library).
# If unset and several libraries contain Rcpp, the newest packageVersion("Rcpp") wins.

ov <- Sys.getenv("GLMBAYES_RCPP_LIB", "")
lp <- .libPaths()
hits <- Filter(function(L) file.exists(file.path(L, "Rcpp", "DESCRIPTION")), lp)

if (!length(hits)) {
  writeLines("configure: no Rcpp under .libPaths(); install Rcpp before building", con = stderr())
  quit(status = 1L)
}

pick_lib <- function() {
  if (nzchar(ov)) {
    d <- ov
    if (!file.exists(file.path(d, "Rcpp", "DESCRIPTION"))) {
      writeLines(sprintf("configure: GLMBAYES_RCPP_LIB=%s does not contain Rcpp", ov), con = stderr())
      quit(status = 1L)
    }
    writeLines(sprintf("configure: Rcpp include from GLMBAYES_RCPP_LIB=%s", d), con = stderr())
    return(d)
  }
  if (length(hits) == 1L) {
    writeLines(sprintf("configure: single Rcpp installation: %s", hits[[1L]]), con = stderr())
    return(hits[[1L]])
  }
  best <- hits[[1L]]
  bv <- packageVersion("Rcpp", lib.loc = best)
  for (i in 2L:length(hits)) {
    v <- packageVersion("Rcpp", lib.loc = hits[[i]])
    if (v > bv) {
      best <- hits[[i]]
      bv <- v
    }
  }
  writeLines(sprintf("configure: multiple Rcpp — using newest (%s): %s", as.character(bv), best), con = stderr())
  for (L in hits) {
    if (!identical(L, best)) {
      writeLines(
        sprintf("configure:   (other) %s @ %s", L, as.character(packageVersion("Rcpp", lib.loc = L))),
        con = stderr()
      )
    }
  }
  best
}

parse_rcpp_minimum_version <- function() {
  if (!file.exists("DESCRIPTION")) {
    return(NULL)
  }
  imp <- tryCatch(
    read.dcf("DESCRIPTION", fields = "Imports")[[1L]],
    error = function(e) ""
  )
  imp <- gsub("[\n\r]", " ", imp, perl = TRUE)
  m <- regexec("Rcpp\\s*\\(>=\\s*([0-9.]+)\\)", imp, perl = TRUE)
  r <- regmatches(imp, m)[[1L]]
  if (length(r) < 2L) {
    return(NULL)
  }
  tryCatch(package_version(r[[2L]]), warning = function(w) NULL, error = function(e) NULL)
}

rcpp_configure_version_info <- function(lib) {
  # Version + library are echoed by configure / configure.win from stdout line 1 (see below).
  rv <- getRversion()
  r_svn <- tryCatch({
    v <- R.version
    s <- if (!is.null(v[["svn.rev"]])) v[["svn.rev"]] else v[["svn rev"]]
    s <- as.character(s)
    if (!length(s) || !nzchar(s)) "unknown" else s
  }, error = function(e) "unknown")
  writeLines(
    sprintf("configure: R version: %s (svn: %s)", as.character(rv), r_svn),
    con = stderr()
  )

  pd <- tryCatch(
    suppressWarnings(packageDescription("Rcpp", lib.loc = lib)),
    error = function(e) NULL
  )
  if (is.list(pd) && !identical(pd, NA)) {
    rs <- pd[["RemoteSha"]]
    if (!is.null(rs) && length(rs) && nzchar(as.character(rs)[1L])) {
      writeLines(sprintf("configure: Rcpp RemoteSha: %s", as.character(rs)[1L]), con = stderr())
    }
    gr <- pd[["GithubRepo"]]
    gu <- pd[["GithubUsername"]]
    if (!is.null(gr) && nzchar(as.character(gr)) && !is.null(gu) && nzchar(as.character(gu))) {
      writeLines(sprintf("configure: Rcpp source: %s/%s", as.character(gu)[1L], as.character(gr)[1L]), con = stderr())
    }
    rp <- pd[["Repository"]]
    if (!is.null(rp) && nzchar(as.character(rp))) {
      writeLines(sprintf("configure: Rcpp Repository: %s", as.character(rp)[1L]), con = stderr())
    }
  }
  fh <- file.path(lib, "Rcpp", "include", "Rcpp", "Function.h")
  if (file.exists(fh)) {
    h <- readLines(fh, warn = FALSE)
    has_ub <- any(grepl("R_getVarEx", h, fixed = TRUE) & grepl("R_UnboundValue", h, fixed = TRUE))
    writeLines(
      sprintf(
        "configure: Rcpp Function.h: line with R_getVarEx + R_UnboundValue present = %s",
        has_ub
      ),
      con = stderr()
    )
  }
  invisible()
}

rcpp_configure_warnings <- function(lib) {
  rv <- getRversion()
  r_svn <- tryCatch({
    v <- R.version
    s <- if (!is.null(v[["svn.rev"]])) v[["svn.rev"]] else v[["svn rev"]]
    as.integer(as.character(s))
  }, error = function(e) NA_integer_)
  r_devel <- nzchar(R.version$status) && grepl("devel|Under development", R.version$status, ignore.case = TRUE)
  r_ge_45 <- rv >= "4.5.0"

  v_inst <- tryCatch(packageVersion("Rcpp", lib.loc = lib), error = function(e) NULL)
  if (!is.null(v_inst)) {
    vmin <- parse_rcpp_minimum_version()
    if (!is.null(vmin) && v_inst < vmin) {
      writeLines(sprintf(
        "configure: WARNING: installed Rcpp %s is older than DESCRIPTION Imports (>= %s).",
        as.character(v_inst), as.character(vmin)
      ), con = stderr())
    }
  }

  if (identical(as.character(rv), "4.6.0") && !is.na(r_svn) && r_svn < 89746L) {
    writeLines(
      sprintf(
        "configure: WARNING: R 4.6.0 snapshot r%d is older than the Rcpp 1.1.1-1 compatibility cutoff (r89746).",
        r_svn
      ),
      con = stderr()
    )
    writeLines(
      "configure: WARNING: Recommendation: update R to >= 4.6.0 r89746 (or current release) before building with recent Rcpp.",
      con = stderr()
    )
  }

  pd <- tryCatch(
    suppressWarnings(packageDescription("Rcpp", lib.loc = lib)),
    error = function(e) NULL
  )
  if (identical(pd, NA)) {
    return(invisible())
  }
  has_remote <- any(vapply(
    c("RemoteSha", "GithubRepo", "GithubUsername"),
    function(f) {
      v <- pd[[f]]
      !is.null(v) && length(v) && nzchar(as.character(v)[1L])
    },
    FUN.VALUE = logical(1L)
  ))
  repo <- pd[["Repository"]]
  repo_cran <- !is.null(repo) && identical(as.character(repo), "CRAN")
  repo_unknown <- is.null(repo) || !nzchar(as.character(repo))

  if ((r_devel || r_ge_45) && !has_remote && (repo_cran || repo_unknown)) {
    writeLines("configure: WARNING: Rcpp looks like a CRAN install (no GitHub Remote* fields).", con = stderr())
    writeLines("configure: WARNING: On R-devel / R >= 4.5, stale CRAN headers can be incompatible", con = stderr())
    writeLines("configure: WARNING: with R (e.g. R_NamespaceRegistry). Consider", con = stderr())
    writeLines("configure: WARNING: remotes::install_github(\"RcppCore/Rcpp\") or ensure", con = stderr())
    writeLines("configure: WARNING: install_github actually replaced the library.", con = stderr())
  }

  fh <- file.path(lib, "Rcpp", "include", "Rcpp", "Function.h")
  if (file.exists(fh)) {
    txt <- paste(readLines(fh, warn = FALSE), collapse = "\n")
    if (grepl("R_getVarEx\\([^)]*R_NamespaceRegistry[^)]*R_UnboundValue", txt, perl = TRUE)) {
      writeLines(
        paste0(
          "configure: WARNING: Rcpp Function.h matches CRAN-style R_UnboundValue line. ",
          "If compilation fails with R_NamespaceRegistry, reinstall Rcpp from GitHub or use a patched header."
        ),
        con = stderr()
      )
    }
  }
  invisible()
}

lib <- pick_lib()
rcpp_configure_version_info(lib)
rcpp_configure_warnings(lib)

ver <- tryCatch(as.character(packageVersion("Rcpp", lib.loc = lib)), error = function(e) "unknown")
# Line 1 for configure / configure.win: version TAB library (no tabs in path assumed).
cat(sprintf("%s\t%s\n", ver, lib))
inc <- normalizePath(
  system.file("include", package = "Rcpp", lib.loc = lib),
  winslash = "/",
  mustWork = TRUE
)
p <- gsub("\\\\", "/", inc)
# Line 2: PKG_CPPFLAGS fragment for Makevars (single line).
cat(sprintf('-I"%s"\n', p))
