# Package attach hook: OpenCL build / runtime advisory for developer workflows.

.opencl_startup_quiet <- function() {
  isTRUE(getOption("nmathopencl.quiet_opencl_startup", FALSE)) || !interactive()
}

.opencl_doc_hint <- function() {
  paste0(
    "  Documentation: ?gpu_diagnostics, ",
    "vignette(\"Chapter-12\", \"nmathopencl\"), ?nmathopencl-package."
  )
}

.opencl_runtime_sniff <- function() {
  tryCatch(
    {
      info <- detect_environment_and_gpus()
      rt_list <- detect_compute_runtimes(info)
      gpu <- isTRUE(info$nvidia$present) ||
        isTRUE(info$amd$present) ||
        isTRUE(info$intel$present)
      stack_ok <- FALSE
      for (vendor in c("nvidia", "amd", "intel")) {
        ocl <- rt_list$runtimes[[vendor]]$opencl
        if (isTRUE(ocl$installed) ||
            (isTRUE(ocl$headers_present) && isTRUE(ocl$runtime_present))) {
          stack_ok <- TRUE
          break
        }
      }
      list(gpu = gpu, stack_ok = stack_ok, environment = info$environment)
    },
    error = function(e) {
      list(gpu = FALSE, stack_ok = FALSE, environment = "unknown")
    }
  )
}

.opencl_startup_message <- function() {
  if (.opencl_startup_quiet()) {
    return(invisible())
  }
  if (isTRUE(getOption("nmathopencl.opencl_startup_checked", FALSE))) {
    return(invisible())
  }
  options(nmathopencl.opencl_startup_checked = TRUE)

  nmath_ok <- isTRUE(tryCatch(has_opencl(), error = function(e) FALSE))
  tools_ok <- isTRUE(tryCatch(opencltools::has_opencl(), error = function(e) FALSE))

  if (tools_ok && !nmath_ok) {
    packageStartupMessage(
      "Note: CPU fallbacks and non-GPU development remain available in nmathopencl.\n",
      "  opencltools was built with OpenCL support but nmathopencl was not; GPU\n",
      "  kernels and OpenCL wrappers require reinstalling nmathopencl from source\n",
      "  with OpenCL headers and libraries at compile time.\n",
      .opencl_doc_hint()
    )
    return(invisible())
  }

  if (nmath_ok && !tools_ok) {
    packageStartupMessage(
      "Note: CPU fallbacks and non-GPU development remain available in nmathopencl.\n",
      "  nmathopencl was built with OpenCL support but opencltools was not;\n",
      "  reinstall opencltools from source with OpenCL available at compile time.\n",
      .opencl_doc_hint()
    )
    return(invisible())
  }

  if (nmath_ok && tools_ok) {
    return(invisible())
  }

  sniff <- .opencl_runtime_sniff()

  if (isTRUE(sniff$stack_ok)) {
    packageStartupMessage(
      "Note: CPU fallbacks and non-GPU development remain available in nmathopencl.\n",
      "  OpenCL headers/runtime appear present, but nmathopencl and opencltools\n",
      "  were installed without OpenCL compile support. Reinstall both from source\n",
      "  to enable GPU kernels and OpenCL wrappers (setup may require extra work).\n",
      .opencl_doc_hint()
    )
    return(invisible())
  }

  if (isTRUE(sniff$gpu)) {
    packageStartupMessage(
      "Note: CPU fallbacks and non-GPU development remain available in nmathopencl.\n",
      "  This install lacks OpenCL compile support; GPU hardware may be present but\n",
      "  a full OpenCL stack was not detected. Install or repair drivers, OpenCL ICD,\n",
      "  and development headers, then reinstall both packages from source.\n",
      .opencl_doc_hint()
    )
    return(invisible())
  }

  packageStartupMessage(
    "Note: CPU fallbacks and non-GPU development remain available in nmathopencl.\n",
    "  This install has no OpenCL compile support and no suitable GPU/OpenCL\n",
    "  environment was detected. OpenCL kernel work needs a supported GPU stack\n",
    "  and a source install of nmathopencl and opencltools.\n",
    .opencl_doc_hint()
  )
  invisible()
}

.onAttach <- function(libname, pkgname) {
  .opencl_startup_message()
}
