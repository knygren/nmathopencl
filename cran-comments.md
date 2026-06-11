# CRAN submission comments --- nmathopencl 0.8.2

Resubmission addressing the three items of reviewer feedback on 0.8.1.

## 1. Method references in the Description field

Added in the requested auto-linking format: R Core Team (2026)
<doi:10.32614/R.manuals> for the ported 'nmath'/'Rmath' ('Mathlib') sources,
Stone, Gohara, and Shi (2010) <doi:10.1109/MCSE.2010.69> for the 'OpenCL'
standard, and Nygren and Nygren (2006) <doi:10.1198/016214506000000357> for
the likelihood subgradient methodology used by the illustrative GLM kernel
subsystem. Any incoming spell-check NOTE on author surnames (e.g. "Gohara")
refers to proper names in these references.

In addition, the algorithm references cited on the corresponding CPU help
pages in R (stats/base) are now mirrored onto the exported `*_opencl` help
pages via 'Rdpack'.

## 2. Commented-out code in examples

(`bessel_opencl.Rd`, `beta_opencl.Rd`, `gamma_opencl.Rd`,
`rext_utils_opencl.Rd`, `signrank_opencl.Rd`, `wilcox_opencl.Rd`)

All commented-out example lines have been removed; remaining examples are
runnable toy examples. The wrappers those lines referred to have documented
OpenCL device failures and are no longer exported (internal-only); their help
pages were removed where no exported functions remain.

## 3. Authors, contributors, and copyright holders in `Authors@R`

(e.g. "The Khronos Group Inc" in `cl.h`)

We audited every bundled or derived source file (all 'OpenCL' routine ports
under `inst/cl/nmath/`, the C sources under `src/` and `src/nmath/`, and the
bundled headers under `inst/include/`) against the AUTHOR and copyright
notices in the file headers. As a result:

- `person("The Khronos Group Inc", role = "cph")` added for the bundled
  'OpenCL' API headers `inst/include/CL/cl.h` and `cl_platform.h`
  (Apache License 2.0; original notices preserved in the file headers).
  The `License` field was widened from `GPL-2` to `GPL (>= 2)` so the
  Apache-2.0-licensed headers are license-compatible.
- `ctb` entries added for every individual credited as a code author in the
  ported R 'Mathlib' sources: Catherine Loader (dbinom/bd0/stirlerr density
  routines), Claus Ekstrom (dnt), Peter Ruckdeschel (dnf), and Alfred H.
  Morris, Jr. and Armido R. Didonato (ACM TOMS 708 incomplete beta code).
  Morten Welinder, Ross Ihaka, Robert Gentleman, Martin Maechler, The R Core
  Team, and The R Foundation were already listed.
- One contributor entry specific to R's glm() implementation was removed:
  no glm code is copied or derived in this package (its GLM-related example
  layer is original integration/teaching code).
- `inst/COPYRIGHTS` was expanded with a per-component map of the above; all
  original AUTHOR/copyright notices remain preserved in the individual
  source file headers.

## Test environments (0.8.2)

- Maintainer: Windows 11, R 4.6.0, OpenCL (NVIDIA).
- Optional OpenCL: CPU fallbacks via 'stats' when OpenCL is absent at compile
  time; GPU tests are skipped on CRAN (`skip_on_cran()`).

---
_This file is listed in `.Rbuildignore` and is not included in the
built source tarball. Paste into the CRAN submission "Optional comments"
field at https://cran.r-project.org/submit.html_
