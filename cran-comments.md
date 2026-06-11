# CRAN submission comments --- nmathopencl 0.8.2

Resubmission after first CRAN `R CMD check` on **0.8.0** (initial release).

## Notes for reviewers

- First public CRAN release of **nmathopencl** (developer OpenCL Mathlib library).
- Optional OpenCL: CPU fallbacks when OpenCL is absent at compile time
  (`nmathopencl_has_opencl()` is `FALSE`).
- **`DESCRIPTION`**: `'OpenCL'`, `'Mathlib'`, and `'opencltools'` are
  single-quoted in the Description field.

## Response to CRAN reviewer feedback on 0.8.1

1. **Commented-out code in examples** (`bessel_opencl.Rd`, `beta_opencl.Rd`,
   `gamma_opencl.Rd`, `rext_utils_opencl.Rd`, `signrank_opencl.Rd`,
   `wilcox_opencl.Rd`): all commented-out example lines removed. The wrappers
   those lines referred to have documented OpenCL device failures and are no
   longer exported (internal-only); their help pages were removed where no
   exported functions remain. Remaining examples are runnable toy examples.

2. **References in Description**: added in the requested format —
   R Core Team (2026) <doi:10.32614/R.manuals> for the ported 'nmath'/'Rmath'
   ('Mathlib') sources, Stone, Gohara, and Shi (2010) <doi:10.1109/MCSE.2010.69>
   for the 'OpenCL' standard, and Nygren and Nygren (2006)
   <doi:10.1198/016214506000000357> for the likelihood subgradient methodology
   used by the illustrative GLM kernel subsystem. Any incoming spell-check NOTE
   on the author surnames (e.g. "Gohara") refers to proper names in these
   references.

3. **Authors, contributors, and copyright holders in `Authors@R`** (e.g. "The
   Khronos Group Inc" in `cl.h`): we audited every bundled or derived source
   file (all 137 'OpenCL' routine ports under `inst/cl/nmath/`, the C sources
   under `src/` and `src/nmath/`, and the bundled headers under
   `inst/include/`) against the AUTHOR and copyright notices in the file
   headers. As a result:
   - `person("The Khronos Group Inc", role = "cph")` added for the bundled
     'OpenCL' API headers `inst/include/CL/cl.h` and `cl_platform.h`
     (Apache License 2.0; original notices preserved in the file headers).
     The `License` field was widened from `GPL-2` to `GPL (>= 2)` so the
     Apache-2.0-licensed headers are license-compatible.
   - `ctb` entries added for every individual credited as a code author in
     the ported R 'Mathlib' sources: Catherine Loader (dbinom/bd0/stirlerr
     density routines), Claus Ekstrom (dnt), Peter Ruckdeschel (dnf), and
     Alfred H. Morris, Jr. and Armido R. Didonato (ACM TOMS 708 incomplete
     beta code). Morten Welinder, Ross Ihaka, Robert Gentleman, Martin
     Maechler, The R Core Team, and The R Foundation were already listed.
   - One contributor entry specific to R's glm() implementation was removed:
     no glm code is copied or derived in this package (its GLM-related
     example layer is original integration/teaching code).
   - `inst/COPYRIGHTS` was expanded with a per-component map of the above,
     and all original AUTHOR/copyright notices remain preserved in the
     individual source file headers.
   - The algorithm references from the corresponding CPU help pages in R
     (stats/base) were additionally mirrored onto the package's help pages
     via `Rdpack`, so the methodological literature for each ported routine
     is cited on its 'OpenCL' wrapper page.

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
