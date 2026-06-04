#' GPU and OpenCL diagnostics for \pkg{nmathopencl}
#'
#' @description
#' Compile-time and device-selection probes for \pkg{nmathopencl}, plus
#' \code{diagnose_glmbayes()} --- a readable report that combines
#' \pkg{opencltools} host/runtime checks with this package's OpenCL build
#' status (\code{\link{has_opencl}}).
#'
#' Low-level workstation probes (GPU vendor detection, driver and ICD checks,
#' PATH validation, \code{verify_opencl_runtime()}, PATH helpers, etc.) live in
#' \pkg{opencltools}; call them as \code{opencltools::detect_environment_and_gpus()},
#' \code{opencltools::diagnose_glmbayes()} (opencltools-only report), and related
#' topics documented under \code{?opencltools}.
#'
#' @section Diagnostics exported from \pkg{nmathopencl}:
#' \itemize{
#'   \item \code{\link{diagnose_glmbayes}()} --- full report including
#'     \pkg{nmathopencl} compile-time OpenCL status.
#'   \item \code{\link{has_opencl}()} --- \code{TRUE} if this build was compiled
#'     with OpenCL support.
#'   \item \code{\link{opencl_device_info}()}, \code{\link{opencl_fp64_available}()} ---
#'     cached double-precision device selection for kernels.
#'   \item \code{\link{opencl_reset_device_selection}()} --- clear device cache.
#' }
#'
#' @section Host / runtime checks (\pkg{opencltools}):
#' \itemize{
#'   \item \code{\link[opencltools:gpu_diagnostics]{detect_environment_and_gpus}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{detect_compute_runtimes}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{verify_opencl_runtime}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{check_runtime_env}()}
#'   \item \code{\link[opencltools:add_to_path]{add_to_path_windows}()} and related PATH helpers
#' }
#'
#' @details
#' GPU acceleration uses OpenCL kernels and \code{*_opencl} wrappers when
#' \code{\link{has_opencl}()} is \code{TRUE} and a suitable device is available
#' (\insertCite{Stone2010}{nmathopencl}). CPU fallbacks apply for many routines
#' when OpenCL is absent at compile time or runtime.
#'
#' Start with \code{\link{diagnose_glmbayes}()} for a single readable report;
#' use \code{\link{has_opencl}()} for a quick boolean when scripting. Setup:
#' \code{vignette("Chapter-01", package = "nmathopencl")}; packaged GPU API:
#' \code{vignette("Chapter-12", package = "nmathopencl")}.
#'
#' @seealso
#' \code{\link{diagnose_glmbayes}}, \code{\link{has_opencl}},
#' \code{\link{opencl_device_info}}, \pkg{opencltools}.
#'
#' @references
#' \insertAllCited{}
#' @importFrom Rdpack reprompt
#' @keywords diagnostics gpu opencl environment
#' @name gpu_diagnostics
NULL


#' @export
#' @rdname gpu_diagnostics
#' @order 1
diagnose_glmbayes <- function() {
  cat("=== nmathopencl OpenCL Diagnostic Report ===\n")

  # Step 1: Environment + GPU detection (opencltools)
  info     <- opencltools::detect_environment_and_gpus()
  drivers  <- opencltools::detect_or_install_gpu_drivers(info)
  runtimes <- opencltools::detect_compute_runtimes(info)
  env_diag <- opencltools::check_runtime_env(runtimes)

  cat("Environment:", info$environment, "\n\n")

  # Step 2: Preference order (NVIDIA > AMD > Intel)
  gpu_vendor <- if (info$nvidia$present) "nvidia"
  else if (info$amd$present) "amd"
  else if (info$intel$present) "intel"
  else NULL

  diag <- NULL
  runtime_ok <- NA

  if (!is.null(gpu_vendor)) {
    cat("GPU:", toupper(gpu_vendor), "\n")
    drv  <- drivers$drivers[[gpu_vendor]]
    rt   <- runtimes$runtimes[[gpu_vendor]]
    diag <- env_diag$diagnostics[[gpu_vendor]]

    if (drv$installed) {
      cat("  [OK] Driver installed\n")
    } else {
      cat("  [FAIL] Driver not installed\n")
      if (length(drv$issues) > 0)
        cat("    Issues:", paste(drv$issues, collapse=", "), "\n")
    }

    hdr <- rt$opencl$headers_present
    rtm <- rt$opencl$runtime_present
    inst <- rt$opencl$installed

    if (hdr) {
      cat("  [OK] OpenCL headers found (CL/cl.h)\n")
    } else {
      cat("  [FAIL] OpenCL headers not found (CL/cl.h missing)\n")
    }

    if (rtm) {
      cat("  [OK] OpenCL runtime found (OpenCL.dll / ICD)\n")
    } else {
      cat("  [FAIL] OpenCL runtime not found\n")
    }

    if (inst) {
      cat("  [OK] OpenCL fully available (headers + runtime)\n")
    } else {
      cat("  [FAIL] OpenCL incomplete (missing headers or runtime)\n")
    }

    paths_ok <- (length(diag$opencl$missing_path_dirs) == 0 &&
                   length(diag$opencl$missing_lib_dirs) == 0)

    if (paths_ok) {
      cat("  [OK] Required PATH and library dirs present\n")
    } else {
      if (length(diag$opencl$missing_path_dirs) > 0)
        cat("  [WARN] Missing PATH entries:",
            paste(diag$opencl$missing_path_dirs, collapse=", "), "\n")
      if (length(diag$opencl$missing_lib_dirs) > 0)
        cat("  [WARN] Missing library dirs:",
            paste(diag$opencl$missing_lib_dirs, collapse=", "), "\n")
    }

    if (paths_ok && tolower(info$environment) %in% c("linux", "wsl")) {
      runtime_ok <- opencltools::verify_opencl_runtime(rt$opencl$lib_dirs)
      if (runtime_ok) {
        cat("  [OK] OpenCL runtime probe succeeded (platform available)\n")
      } else {
        cat("  [FAIL] OpenCL runtime probe failed (no usable platform)\n")
      }
    } else if (!paths_ok) {
      cat("  [SKIP] Runtime probe skipped (missing PATH/lib dirs)\n")
    } else {
      cat("  [SKIP] Runtime probe skipped on Windows\n")
    }

  } else {
    cat("[FAIL] No supported GPU detected. CPU fallbacks remain available.\n")
  }

  # Step 3: Report compile-time OpenCL status (nmathopencl build)
  opencl_enabled <- has_opencl()
  if (opencl_enabled) {
    cat("\n[OK] nmathopencl was compiled with OpenCL support.\n")
  } else {
    cat("\n[FAIL] nmathopencl was compiled without OpenCL support.\n")
  }

  # Step 4: Interactive PATH/lib fixes
  missing_items <- !is.null(diag) &&
    (length(diag$opencl$missing_path_dirs) > 0 ||
       length(diag$opencl$missing_lib_dirs) > 0)

  if (missing_items && !isTRUE(opencl_enabled)) {
    cat("\n[INFO] Missing PATH/lib entries detected and OpenCL is not enabled.\n")

    if (length(diag$opencl$missing_path_dirs) > 0) {
      cat("  Missing PATH entries:\n")
      cat("   -", paste(diag$opencl$missing_path_dirs, collapse="\n   - "), "\n")
      ans <- readline("Would you like to permanently add missing PATH dirs? [y/N]: ")
      if (tolower(ans) == "y") {
        if (tolower(info$environment) == "windows") {
          opencltools::add_to_path_windows(diag$opencl$missing_path_dirs)
        } else {
          opencltools::add_to_path_linux(diag$opencl$missing_path_dirs)
        }
      }
    }

    if (length(diag$opencl$missing_lib_dirs) > 0 &&
        tolower(info$environment) %in% c("linux", "wsl")) {
      cat("  Missing library dirs:\n")
      cat("   -", paste(diag$opencl$missing_lib_dirs, collapse="\n   - "), "\n")
      ans_lib <- readline("Would you like to permanently add missing library dirs to LD_LIBRARY_PATH? [y/N]: ")
      if (tolower(ans_lib) == "y") {
        opencltools::add_to_libpath_linux(diag$opencl$missing_lib_dirs)
      }
    }
  }

  cat("\n=== End of Diagnostic Report ===\n")

  invisible(list(
    environment_info      = info,
    driver_status         = drivers,
    runtime_status        = runtimes,
    env_diag              = env_diag,
    opencl_runtime_probe  = runtime_ok,
    opencl_enabled        = opencl_enabled
  ))
}


#' @export
#' @rdname gpu_diagnostics
#' @order 2
has_opencl <- function() {
  .has_opencl_cpp()
}


#' @describeIn gpu_diagnostics Cached OpenCL device selection for double-precision
#'   (\code{cl_khr_fp64}) kernels: enumerates platforms and devices, prefers GPU,
#'   checks the extension token, then verifies with a tiny \code{clBuildProgram}
#'   probe. Override with environment variables \code{NMATHOPENCL_PLATFORM_INDEX}
#'   and/or \code{NMATHOPENCL_DEVICE_INDEX} (0-based; device index is within the
#'   platform's device list). Use \code{\link{opencl_reset_device_selection}()}
#'   to clear the cache (e.g. after driver changes).
#'
#' @param force If \code{TRUE}, rerun discovery even when a previous selection is cached.
#' @param details If \code{TRUE}, include a \code{candidates} list describing every
#'   platform/device pair (extension flag and probe result per device).
#'
#' @return \code{opencl_device_info} returns a list with \code{ok} (logical),
#'   \code{reason} (character), indices, vendor/name strings, \code{device_type},
#'   \code{extension_cl_khr_fp64}, \code{probe_fp64_ok}, \code{selection_policy},
#'   and optionally \code{candidates}.
#'
#' @export
#' @order 3
opencl_device_info <- function(force = FALSE, details = FALSE) {
  opencl_device_info_cpp_export(as.logical(force)[[1L]], as.logical(details)[[1L]])
}

#' @describeIn gpu_diagnostics Returns \code{TRUE} if a cached OpenCL device passes
#'   the \code{cl_khr_fp64} extension check and build probe used for double kernels.
#'
#' @export
#' @order 4
opencl_fp64_available <- function(force = FALSE) {
  opencl_fp64_available_cpp_export(as.logical(force)[[1L]])
}

#' @describeIn gpu_diagnostics Clears the process-local OpenCL device selection cache
#'   so the next kernel or \code{\link{opencl_device_info}()} run re-enumerates devices.
#'
#' @export
#' @order 5
opencl_reset_device_selection <- function() {
  invisible(opencl_reset_device_selection_cpp_export())
}
