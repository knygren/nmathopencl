# CRAN submission comments --- nmathopencl 0.8.0

Initial submission of **nmathopencl** to CRAN.

## Notes for reviewers

- This is the first CRAN release (version **0.8.0**).
- Optional OpenCL: the package builds and runs on CPU when OpenCL is not
  available at compile time (`nmathopencl_has_opencl()` is `FALSE`).
- **`DESCRIPTION`**: software names including `'OpenCL'`, `'Mathlib'`, and
  `'opencltools'` are single-quoted in the Description field per incoming
  spell-check guidance.
- Host/runtime diagnostics are delegated to the imported package
  **opencltools** (now on CRAN); see `?gpu_diagnostics` and vignette Chapter 01.

## `R CMD check` results

The current source passes **without errors or warnings** on:

- Local Windows (maintainer machine)
- [R-universe](https://knygren.r-universe.dev/nmathopencl)
- [Winbuilder](https://win-builder.r-project.org/)
- [macbuilder](https://mac.r-project.org/macbuilder/submit.html)
- [R-hub](https://r-hub.github.io/rhubman/)

**Winbuilder** reported a single **NOTE** on the earlier upload:

1. **CRAN incoming — new submission** (expected for a first-time package).
2. **Possibly misspelled word in DESCRIPTION:** `opencltools` (line 29).

The spelling NOTE is addressed in this resubmission: `opencltools` is now
single-quoted as `'opencltools'` in the Description field. The dependency is
a real package (on CRAN), not a typo.

## Test environments

- Local: Windows 11, R 4.6.0, GCC 14.2 (rtools45), NVIDIA OpenCL.
- R-universe, Winbuilder, macbuilder, and R-hub: as above (0 errors, 0 warnings;
  Winbuilder NOTE resolved as described).

---
_This file is listed in `.Rbuildignore` and is not included in the
built source tarball. When submitting, paste the content above into the
"Optional comments" field on the CRAN submission form at
https://cran.r-project.org/submit.html_
