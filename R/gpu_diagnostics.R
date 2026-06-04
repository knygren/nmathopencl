#' GPU and OpenCL diagnostics for \pkg{nmathopencl}
#'
#' @description
#' Compile-time and device-selection probes for \pkg{nmathopencl}.
#'
#' Low-level workstation probes (GPU vendor detection, driver and ICD checks,
#' PATH validation, \code{verify_opencl_runtime()}, PATH helpers, combined
#' diagnostic reports, etc.) live in \pkg{opencltools}; call them as
#' \code{opencltools::detect_environment_and_gpus()},
#' \code{opencltools::diagnose_glmbayes()}, and related topics documented under
#' \code{?opencltools}.
#'
#' @section Diagnostics exported from \pkg{nmathopencl}:
#' \itemize{
#'   \item \code{\link{nmathopencl_has_opencl}()} --- \code{TRUE} if this build was compiled
#'     with OpenCL support.
#'   \item \code{\link{nmathopencl_opencl_device_info}()},
#'     \code{\link{nmathopencl_opencl_fp64_available}()} ---
#'     cached double-precision device selection for kernels.
#'   \item \code{\link{nmathopencl_opencl_reset_device_selection}()} --- clear device cache.
#'   \item \code{\link[opencltools:get_opencl_core_count]{opencltools::get_opencl_core_count}()} ---
#'     compute units on the opencltools default device.
#' }
#'
#' @section Host / runtime checks (\pkg{opencltools}):
#' \itemize{
#'   \item \code{\link[opencltools:gpu_diagnostics]{detect_environment_and_gpus}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{detect_compute_runtimes}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{verify_opencl_runtime}()}
#'   \item \code{\link[opencltools:gpu_diagnostics]{check_runtime_env}()}
#'   \item \code{\link[opencltools:diagnose_glmbayes]{opencltools::diagnose_glmbayes}()}
#'   \item \code{\link[opencltools:add_to_path]{add_to_path_windows}()} and related PATH helpers
#' }
#'
#' @details
#' GPU acceleration uses OpenCL kernels and \code{*_opencl} wrappers when
#' \code{\link{nmathopencl_has_opencl}()} is \code{TRUE} and a suitable device is available
#' (\insertCite{Stone2010}{nmathopencl}). CPU fallbacks apply for many routines
#' when OpenCL is absent at compile time or runtime.
#'
#' For a readable host/runtime report, use \code{\link[opencltools:diagnose_glmbayes]{opencltools::diagnose_glmbayes}()};
#' use \code{\link{nmathopencl_has_opencl}()} for this package's compile-time flag.
#' Setup: \code{vignette("Chapter-01", package = "nmathopencl")}; packaged GPU API:
#' \code{vignette("Chapter-12", package = "nmathopencl")}.
#'
#' @seealso
#' \code{\link{nmathopencl_has_opencl}},
#' \code{\link{nmathopencl_opencl_device_info}}, \pkg{opencltools}.
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
nmathopencl_has_opencl <- function() {
  .nmathopencl_has_opencl_cpp()
}


#' @describeIn gpu_diagnostics Cached OpenCL device selection for double-precision
#'   (\code{cl_khr_fp64}) kernels in \pkg{nmathopencl}: enumerates platforms and devices, prefers GPU,
#'   checks the extension token, then verifies with a tiny \code{clBuildProgram}
#'   probe. Override with environment variables \code{NMATHOPENCL_PLATFORM_INDEX}
#'   and/or \code{NMATHOPENCL_DEVICE_INDEX} (0-based; device index is within the
#'   platform's device list). Use \code{\link{nmathopencl_opencl_reset_device_selection}()}
#'   to clear the cache (e.g. after driver changes).
#'
#' @param force If \code{TRUE}, rerun discovery even when a previous selection is cached.
#' @param details If \code{TRUE}, include a \code{candidates} list describing every
#'   platform/device pair (extension flag and probe result per device).
#'
#' @return A list with \code{ok} (logical),
#'   \code{reason} (character), indices, vendor/name strings, \code{device_type},
#'   \code{extension_cl_khr_fp64}, \code{probe_fp64_ok}, \code{selection_policy},
#'   and optionally \code{candidates}.
#'
#' @export
#' @order 2
nmathopencl_opencl_device_info <- function(force = FALSE, details = FALSE) {
  nmathopencl_opencl_device_info_cpp_export(
    as.logical(force)[[1L]],
    as.logical(details)[[1L]]
  )
}

#' @describeIn gpu_diagnostics Returns \code{TRUE} if a cached OpenCL device passes
#'   the \code{cl_khr_fp64} extension check and build probe used for double kernels
#'   in \pkg{nmathopencl} (uses this package's compile-time OpenCL build and device
#'   cache, not \pkg{opencltools}).
#'
#' @export
#' @order 3
nmathopencl_opencl_fp64_available <- function(force = FALSE) {
  if (!nmathopencl_has_opencl()) {
    return(FALSE)
  }
  nmathopencl_opencl_fp64_available_cpp_export(as.logical(force)[[1L]])
}

#' @describeIn gpu_diagnostics Clears the process-local OpenCL device selection cache
#'   so the next kernel or \code{\link{nmathopencl_opencl_device_info}()} run re-enumerates devices.
#'
#' @export
#' @order 4
nmathopencl_opencl_reset_device_selection <- function() {
  invisible(nmathopencl_opencl_reset_device_selection_cpp_export())
}
