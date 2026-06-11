# CRAN submission comments --- nmathopencl 0.8.2

Resubmission after first CRAN `R CMD check` on **0.8.0** (initial release).

## Notes for reviewers

- First public CRAN release of **nmathopencl** (developer OpenCL Mathlib library).
- Optional OpenCL: CPU fallbacks when OpenCL is absent at compile time
  (`nmathopencl_has_opencl()` is `FALSE`).
- **`DESCRIPTION`**: `'OpenCL'`, `'Mathlib'`, and `'opencltools'` are
  single-quoted in the Description field.

## Response to CRAN `R CMD check` on 0.8.0

CRAN's **linux-gnu** builder (among others) detected OpenCL headers and
runtime, enabled `USE_OPENCL`, and set `nmathopencl_has_opencl()` to `TRUE`.
That led to **2 ERRORs** on the first upload:

1. **Examples** — CPU fallback called `stats::dnbeta()` (not exported from
   `namespace:stats`). Fixed: example uses `stats::dbeta`, `stats::pbeta`,
   `stats::rbeta` only in the CRAN branch.

2. **Tests** — OpenCL GPU tests ran when the package was compiled with OpenCL
   on CRAN builders (~7 minutes, then **segmentation fault**). Fixed:
   `skip_opencl_gpu()` calls `testthat::skip_on_cran()` so GPU tests are
   skipped during CRAN `R CMD check` on OpenCL-enabled builds; non-GPU
   validation (e.g. `pgamma` argument check) still runs. Maintainer GPU
   testing: `NOT_CRAN=true`.

Also fixed: **`NEWS.md`** non-version section title; **`opencltools`** spelling
NOTE in Description.

## Pre-submission checks (0.8.0 tarball)

Passed without errors or warnings on maintainer Windows, R-universe,
Winbuilder, macbuilder, and R-hub. Winbuilder incoming NOTE: new submission +
`opencltools` spelling (addressed).

## Test environments (0.8.2)

- Maintainer: Windows 11, R 4.6.0, OpenCL (NVIDIA).
- CRAN: resubmission after fixes above.

---
_This file is listed in `.Rbuildignore` and is not included in the
built source tarball. Paste into the CRAN submission "Optional comments"
field at https://cran.r-project.org/submit.html_
