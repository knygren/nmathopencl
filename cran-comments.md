# CRAN submission comments --- nmathopencl 0.8.3

New submission following CRAN release 0.8.2.

## Changes since 0.8.2

- Ship **`program_preload_manifest.tsv`** (and companion **`program_preload_manifest.rds`**)
  listing the fixed OpenCL prelude in load order for
  **`opencltools::load_program_preload(source_package = "nmathopencl")`**.
- Document full program assembly (prelude + nmath subset + launcher kernel) in
  **`inst/examples/Ex_load_program_preload.R`** and README workflow section.
- Require **`opencltools (>= 0.8.2)`** for the preload manifest and
  **`load_library_for_kernel_cross_package()`** helpers used by downstream
  packages assembling OpenCL programs from **nmathopencl** shards.

## Test environments (0.8.3)

- Maintainer: Windows 11, R 4.6.0, OpenCL (NVIDIA).
- Optional OpenCL: CPU fallbacks via 'stats' when OpenCL is absent at compile
  time; GPU tests are skipped on CRAN (`skip_on_cran()`).

---
_This file is listed in `.Rbuildignore` and is not included in the
built source tarball. Paste into the CRAN submission "Optional comments"
field at https://cran.r-project.org/submit.html_
