# CRAN submission comments — glmbayes 0.9.0

## Test environments

- Local: `R CMD check` / `devtools::check()` on Windows (R version as
  used for release).
- CI: R-hub GitHub Actions workflow (`.github/workflows/rhub.yaml`) for
  additional platforms.

Please update the bullets above with the exact R versions and any rhub
labels you ran before submit.

## R CMD check results

There were 0 ERRORs, 0 WARNINGs, and 0 NOTEs (or paste the final summary
line from your check log).

If your run produced NOTEs, briefly explain each one here.

## Downstream dependencies

There are no reverse dependencies on CRAN (or: revdepcheck was run / not
applicable — adjust as needed).

## Notes for the CRAN team

- **Rcpp**: `DESCRIPTION` requires `Rcpp (>= 1.1.1-1)` for compatibility
  with current `Rcpp` headers and static analysis expectations. If CRAN’s
  Windows binary for `Rcpp` is still at `1.1.1`, users may need a source
  install of `Rcpp` until the Windows binary catches up; that is
  acceptable for this release.

- **OpenCL**: `SystemRequirements` states optional OpenCL; the package
  runs on CPU when OpenCL is unavailable. CRAN’s check farm is expected to
  exercise CPU paths only.

- **Compiled code**: Recent changes address `rchk`-reported protection
  patterns in C++ code; no change to the public R API.

---

This file is listed in `.Rbuildignore`, so it is **not** included in the
built source tarball. Paste these comments into the CRAN submission form
(or attach as instructed by CRAN).
