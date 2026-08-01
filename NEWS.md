# nmathopencl 0.8.4

## Bug fixes

* **Configure:** Removed **`tools/rcpp_include.R`** Rcpp header probing, Function.h
  branch flags, and **`glmbayes_getRegisteredNamespace`** shim (rely on
  **`LinkingTo: Rcpp`** and CRAN **Rcpp** instead).

* **`Suggests`:** Removed **`glmbayes`** while that package is off CRAN
  (avoids CRAN incoming NOTE on non-mainstream repositories).

* **`.Rbuildignore`:** Added **`^\.cursor$`** (hidden directory NOTE).

# nmathopencl 0.8.3

### Program preload manifest and assembly workflow

- Ship **`inst/cl/program_preload_manifest.tsv`** listing the fixed OpenCL prelude
  (headers, R shims, system stubs) in load order, with companion
  **`program_preload_manifest.rds`** for fast R-side reads.
- Regenerate the RDS via **`data-raw/make_program_preload_manifest_rds.R`**
  (uses **`opencltools::write_program_preload_manifest()`**).
- Document full program assembly (prelude + nmath subset + launcher kernel) in
  **`inst/examples/Ex_load_program_preload.R`** and reorder the README workflow
  accordingly.
- Update **`inst/examples/Ex_load_library_for_kernel.R`** to use the smaller
  **`src/dnorm_kernel.cl`** launcher and point to the preload example for the
  full build sequence.
- Require **`opencltools (>= 0.8.2)`** for **`load_program_preload()`**,
  **`load_library_for_kernel_cross_package()`**, and related manifest helpers.

# nmathopencl 0.8.2

This release addresses the three items of CRAN reviewer feedback on the 0.8.1
submission.

### CRAN request 1: method references in the Description field

*"If there are references describing the methods in your package, please add
these in the description field ... in the form authors (year) <doi:...>."*

- Method references added to the Description field in the requested
  auto-linking format: R Core Team (2026) for the ported 'nmath'/'Rmath'
  ('Mathlib') sources, Stone, Gohara, and Shi (2010) for the 'OpenCL'
  standard, and Nygren and Nygren (2006) for the likelihood subgradient
  methodology used by the illustrative GLM kernel subsystem.
- In addition, the algorithm references cited on the corresponding CPU help
  pages in R (`stats`/`base`) are now mirrored onto the exported `*_opencl`
  help pages via `Rdpack` (for example Wichura's AS 241 on `normal_opencl`
  and Didonato & Morris's TOMS 708 on `beta_opencl`).

### CRAN request 2: no commented-out code in examples

*"Some code lines in examples are commented out. Please never do that."
(flagged: `bessel_opencl.Rd`, `beta_opencl.Rd`, `gamma_opencl.Rd`,
`rext_utils_opencl.Rd`, `signrank_opencl.Rd`, `wilcox_opencl.Rd`)*

- All commented-out example lines removed; remaining examples are runnable
  toy examples.
- The commented-out calls referred to wrappers with documented OpenCL port
  failures. Rather than re-enable them, those wrappers are no longer exported
  (internal-only): the Bessel, Wilcoxon rank-sum, and signed-rank families,
  `qbeta_opencl()`, `qgamma_opencl()`, and `r_check_stack_opencl()`. Use the
  `stats`/`base` equivalents (see `inst/OPENCL_KERNEL_KNOWN_FAILURES.md`).
- Help pages `bessel_opencl`, `signrank_opencl`, and `wilcox_opencl` removed
  (no exported functions remain on those pages).

### CRAN request 3: all authors, contributors, and copyright holders in Authors@R

*"Please always add all authors, contributors and copyright holders in the
Authors@R field with the appropriate roles ... e.g.: 'The Khronos Group Inc'
in cl.h."*

- All bundled and derived sources were audited against their AUTHOR and
  copyright headers.
- Added The Khronos Group Inc (`cph`) for the bundled 'OpenCL' API headers in
  `inst/include/CL` (Apache License 2.0), and `ctb` entries for the
  individual R 'Mathlib' code authors whose routines are ported here:
  Catherine Loader, Claus Ekstrøm, Peter Ruckdeschel, Alfred H. Morris, Jr.,
  and Armido R. Didonato.
- Removed a glm-specific contributor entry (no glm code is copied in this
  package).
- `inst/COPYRIGHTS` expanded with a per-component map of the above; all
  original notices remain preserved in the source file headers.
- License widened from `GPL-2` to `GPL (>= 2)` for compatibility with the
  Apache-2.0-licensed Khronos headers.

# nmathopencl 0.8.1

### CRAN check fixes (OpenCL-enabled builders)

- OpenCL GPU **testthat** tests are skipped during CRAN `R CMD check`
  (`skip_on_cran()` via `tests/testthat/helper-opencl.R`) when the package is
  compiled with OpenCL (`USE_OPENCL` / `nmathopencl_has_opencl()` is `TRUE`).
- **`dbeta_opencl` example**: CPU fallback on CRAN no longer calls
  `stats::dnbeta()` (not exported from `namespace:stats`).
- **`NEWS.md`**: version section titles only (CRAN news parser).
- **`DESCRIPTION`**: `'opencltools'` single-quoted in Description.

# nmathopencl 0.8.0

### Initial CRAN release

First public release of **nmathopencl** as a developer library for GPU-accelerated
statistical computing in R.

- **OpenCL-ported Mathlib** — R internal `nmath` routines shipped as `.cl` sources
  under `inst/cl/nmath/` (densities, distributions, quantiles, and random variates),
  plus supporting `R_ext` shims, for inclusion in custom OpenCL kernels.
- **Packaged `*_opencl` API** — exported R wrappers mirroring `stats` families
  (normal, gamma, binomial, Poisson, beta, and many others) that dispatch to GPU
  kernels when OpenCL is available at compile time and fall back to CPU otherwise.
- **C-callable GPU API** — `inst/include/nmathopencl/nmathopencl_capi.h` registers
  **133** `*_opencl` routines for `R_GetCCallable` / downstream C++ packages
  (`LinkingTo: nmathopencl`).
- **Package-local OpenCL probes** — `nmathopencl_has_opencl()`,
  `nmathopencl_opencl_device_info()`, `nmathopencl_opencl_fp64_available()`, and
  `nmathopencl_opencl_reset_device_selection()` for this package's compile-time
  build and fp64 device cache (distinct from **opencltools**).
- **opencltools integration** — kernel assembly via
  `opencltools::load_kernel_*(..., package = "nmathopencl")`; re-exported subset
  loaders and configure helpers (`load_library_for_kernel`, dependency tagging,
  `use_opencl_configure`, …).
- **Worked GLM envelope example** — `Ex_EnvelopeEval` and related `Ex_*` exports
  demonstrate building a custom kernel on top of the ported nmath library
  (pedagogical sandbox; see vignette Chapter 10).
- **Developer documentation** — vignette series (OpenCL setup, kernel authoring,
  linkage patterns, packaged API reference) and examples under `inst/examples/`.

Host and workstation diagnostics (`opencltools::diagnose_glmbayes()`,
`detect_environment_and_gpus()`, PATH helpers, etc.) are provided by the
**opencltools** dependency.

# nmathopencl 0.2.0

### `diagnose_glmbayes()` removed from exports

- Use **`opencltools::diagnose_glmbayes()`** for host/runtime diagnostic reports.

### Package-specific OpenCL diagnostics renamed

- **`has_opencl()`** → **`nmathopencl_has_opencl()`**; **`opencl_device_info()`** →
  **`nmathopencl_opencl_device_info()`**; **`opencl_fp64_available()`** →
  **`nmathopencl_opencl_fp64_available()`**; **`opencl_reset_device_selection()`** →
  **`nmathopencl_opencl_reset_device_selection()`** (distinct from **opencltools**).

### `get_opencl_core_count()` removed from exports

- No longer exported from **nmathopencl**; use **`opencltools::get_opencl_core_count()`**.
  C++ code in this package still calls **`opencltools_get_opencl_core_count()`** via
  `openclPort::get_opencl_core_count()` where needed (e.g. envelope sizing).

### Package-specific fp64 device selection

- **`nmathopencl_opencl_fp64_available()`**, **`nmathopencl_opencl_reset_device_selection()`**, and the
  device cache used by **`nmathopencl_opencl_device_info()`** now use **nmathopencl's** local
  probe in `opencl_device_selection.cpp` (not **`opencltools/opencltools_capi.h`**).
  Kernel loading and core-count helpers still use the opencltools C API from
  `kernel_loader.cpp`. Results follow **`nmathopencl::nmathopencl_has_opencl()`** and this
  package's GPU runtime, not the opencltools build flag.

### Kernel loaders (opencltools only)

- Removed exported **`load_kernel_source()`** and **`load_kernel_library()`** from
  **nmathopencl**; use **`opencltools::load_kernel_*(..., package = "nmathopencl")`**.
  **`load_library_for_kernel`** remains re-exported from **opencltools**.

### C-callable API for downstream packages

- New **`inst/include/nmathopencl/nmathopencl_capi.h`**: `R_GetCCallable` wrappers for
  **133** GPU `*_opencl` routines (SEXP ABI), plus **`nmathopencl_api_version()`** and
  **`nmathopencl_has_opencl()`**.
- New **`src/nmathopencl_ccallables.cpp`**: `extern "C"` implementations and
  **`register_nmathopencl_ccallables_cpp_export()`** (called from **`.onLoad`**).
- Regenerate with **`Rscript tools/generate_nmathopencl_capi.R`** after changing
  **`export_wrappers.cpp`** signatures.
- See **`inst/include/nmathopencl/README.md`** for `Imports` / `LinkingTo` usage.

### CRAN `DESCRIPTION`

- Single-quote `'OpenCL'` and `'Mathlib'` in Title, Description,
  `SystemRequirements`, and `Authors@R` comments (incoming spell-check NOTE).

### Citation and copyright metadata

- **`inst/CITATION`** and **`inst/COPYRIGHTS`** now describe **nmathopencl**
  (replacing leftover **glmbayes** text from the package split).
- **`?nmathopencl-package`**: repository links and vignette pointers updated
  for this package (not **glmbayes**).
- **`inst/CITATION`** / **`inst/REFERENCES.bib`**: add Stone et al. (2010) for
  OpenCL; co-author remains **Lan M. Nygren** (not Lance).

### Examples (`inst/examples/Ex_*_opencl.R`)

- Ported stats/Math `*_opencl` examples call OpenCL when CPU-only or
  `NOT_CRAN=true`; otherwise use **`stats::`** during **`R CMD check`** on
  OpenCL builds (avoids repeated `clBuildProgram` during examples).

### OpenCL C-callable bridge (opencltools)

- **`load_kernel_source()`**, **`load_kernel_library()`**, and C++
  **`load_library_for_kernel()`** now delegate to **opencltools** C-callables
  (`opencltools_load_kernel_*`); redundant loader implementation removed from
  **`src/kernel_loader.cpp`**. Reading **`.cl`** text no longer requires
  **`nmathopencl_has_opencl()`** guards (aligned with **opencltools**).
- Kernel loaders delegate to the opencltools C API. Local fp64 device cache
  remains for kernel runners until **`opencl_bind_selected_fp64_device_or_throw`**
  migrates.
- **`use_opencl_configure()`** and **`port_to_opencl_configure()`** are thin
  re-exports from **opencltools**; configure templates live in
  **`opencltools/inst/configure-templates/`**.
- Tier 3 host/runtime diagnostics (`detect_*`, `verify_opencl_runtime`,
  `gpu_names`, `add_to_path_*`, etc.) are no longer re-exported from
  **nmathopencl**; use **opencltools** directly (including
  **`opencltools::diagnose_glmbayes()`**). **nmathopencl** keeps
  `nmathopencl_has_opencl()` and package-local device-selection helpers.

# nmathopencl 0.1.0

### Documentation and distribution

- `DESCRIPTION`: Title and `Description` now describe OpenCL-ported Mathlib
  (were previously pasted from another package template).
- `README`: R-universe dashboard link and install snippets; status badge for
  <https://knygren.r-universe.dev>.
- **`R-UNIVERSE.md`**: maintainer checklist for R-universe registration and
  automated builds (`configure` / OpenCL notes).
- **`Suggests`**: package `glmbayes (>= 0.9.3)` (CRAN) for vignettes and GPU
  examples that reference envelopes / GLM acceleration.
