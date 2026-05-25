# nmathopencl 0.2.0 (development)

### OpenCL tooling

- Tier 3 host/runtime diagnostics (`detect_*`, `verify_opencl_runtime`,
  `gpu_names`, `add_to_path_*`, etc.) are no longer re-exported from
  **nmathopencl**; use **opencltools** directly. **nmathopencl** keeps
  `diagnose_glmbayes()` (includes this package's compile-time `has_opencl()`
  check), `has_opencl()`, and device-selection helpers.

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
