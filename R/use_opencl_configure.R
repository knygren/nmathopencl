#' Set up OpenCL configure scripts in a downstream R package
#'
#' @description
#' Copies generic OpenCL \code{configure} and \code{configure.win} scripts to
#' the root directory of a package.  The scripts detect \code{CL/cl.h} and
#' \code{libOpenCL} at compile time and generate \code{src/Makevars} (Linux /
#' macOS) or \code{src/Makevars.win} (Windows) with or without
#' \code{-DUSE_OPENCL}, depending on what is found.
#'
#' The scripts \strong{always succeed}.  When no OpenCL SDK is present they
#' produce a CPU-only Makevars with no \code{-lOpenCL}.  This is the key
#' property that makes packages safe for CRAN submission without requiring a
#' GPU SDK on the build machine.  See \code{vignette("Chapter-02",
#' package = "nmathopencl")} for the full downstream package setup guide.
#'
#' @section Why configure scripts are necessary:
#' A package that references \code{-lOpenCL} or \code{CL/cl.h} in a static
#' \code{src/Makevars} will \strong{fail to compile} on CRAN's build machines
#' (which have no GPU SDK installed), and no binary will be produced.  The
#' configure scripts here avoid this by probing for the SDK at install time and
#' falling back to a CPU-only build when it is absent.  The relationship is:
#' \preformatted{
#'   configure / configure.win
#'     -> detects CL/cl.h + libOpenCL
#'     -> writes -DUSE_OPENCL into Makevars   (or omits it)
#'
#'   #ifdef USE_OPENCL in C++ source
#'     -> guards all GPU code; package compiles cleanly either way
#'
#'   has_opencl() in R
#'     -> mirrors the compile-time flag; returns TRUE only if USE_OPENCL was set
#' }
#'
#' @section Migration note:
#' These templates are currently hosted in \pkg{nmathopencl} while
#' \pkg{opencltools} completes its initial CRAN review.  Once \pkg{opencltools}
#' is available, the templates and this function will move there, and
#' \code{nmathopencl::use_opencl_configure} will become a thin re-export of
#' \code{opencltools::use_opencl_configure} --- the same pattern used for the
#' Tier 4 kernel-authoring tools.  No action will be required from downstream
#' package authors; the function signature will not change.
#'
#' @param path Character.  Root directory of the target package.  Defaults to
#'   the current working directory (\code{"."}).
#' @param overwrite Logical.  If \code{TRUE}, overwrite existing configure
#'   scripts.  Defaults to \code{FALSE} to avoid accidentally replacing a
#'   customised script.
#'
#' @return Invisibly returns a character vector of the file paths that were
#'   written (empty if all files were skipped).
#'
#' @seealso
#' \code{vignette("Chapter-02", package = "nmathopencl")} for the full
#' downstream package guide. The template source and migration notes are
#' in \code{system.file("configure-templates", package = "nmathopencl")}.
#'
#' @examples
#' \dontrun{
#' # Copy configure scripts to the current package root:
#' use_opencl_configure()
#'
#' # Copy to a specific package directory:
#' use_opencl_configure(path = "path/to/mypkg")
#'
#' # Overwrite previously copied (unmodified) scripts:
#' use_opencl_configure(overwrite = TRUE)
#' }
#'
#' @export
use_opencl_configure <- function(path = ".", overwrite = FALSE) {
  template_dir <- system.file("configure-templates", package = "nmathopencl")
  if (!nzchar(template_dir) || !dir.exists(template_dir)) {
    stop("configure-templates directory not found in nmathopencl installation.")
  }

  templates <- c("configure", "configure.win")
  written   <- character(0L)

  for (tmpl in templates) {
    src  <- file.path(template_dir, tmpl)
    dest <- file.path(path, tmpl)

    if (!file.exists(src)) {
      warning("Template not found: ", src)
      next
    }

    if (file.exists(dest) && !overwrite) {
      message("Skipping ", tmpl,
              " (already exists; use overwrite = TRUE to replace)")
      next
    }

    ok <- file.copy(src, dest, overwrite = overwrite)
    if (!ok) {
      warning("Could not write ", dest)
      next
    }

    # configure must be executable on Unix for R CMD INSTALL to run it
    if (tmpl == "configure" && .Platform$OS.type != "windows") {
      Sys.chmod(dest, mode = "0755")
    }

    message("Wrote ", dest)
    written <- c(written, dest)
  }

  # Suggest .gitignore entries for generated Makevars files
  gitignore_entries <- c("src/Makevars", "src/Makevars.win")
  gitignore_path    <- file.path(path, ".gitignore")

  if (file.exists(gitignore_path)) {
    existing <- readLines(gitignore_path, warn = FALSE)
    missing  <- setdiff(gitignore_entries, trimws(existing))
    if (length(missing) > 0L) {
      message("\nConsider adding these generated files to .gitignore:")
      message(paste0("  ", missing, collapse = "\n"))
    }
  } else {
    message("\nConsider creating .gitignore with:")
    message(paste0("  ", gitignore_entries, collapse = "\n"))
  }

  # Checklist for the developer
  message(
    "\nNext steps:",
    "\n  1. Guard all OpenCL C++ code with #ifdef USE_OPENCL ... #endif",
    "\n  2. Expose has_opencl() in R via a .Call() to a compiled-in bool",
    "\n     (see nmathopencl::has_opencl for the pattern)",
    "\n  3. Add 'nmathopencl' to LinkingTo in DESCRIPTION (for openclPort.h)",
    "\n  4. Test CPU-only build: R CMD INSTALL --preclean .",
    "\n     (or temporarily rename configure to simulate a no-SDK machine)",
    "\n  5. See vignette(\"Chapter-02\", \"nmathopencl\") for the full guide"
  )

  invisible(written)
}
