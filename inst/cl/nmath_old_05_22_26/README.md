# nmath OpenCL Known Issues

This directory contains OpenCL-translated Mathlib sources.
This note documents known OpenCL port/runtime limitations (not numeric-accuracy validation).

## 1) Device-side memory allocation limitations (`rwilcox` class)

### Symptom
- Build/link failures for unresolved allocation/runtime symbols (for example `R_chk_calloc`).
- Build/link failures for unresolved stack/runtime symbols (for example `R_CheckStack`).
- OpenCL execution path fails and wrapper falls back to CPU.

### Why this happens
- Some upstream Mathlib paths assume host/R runtime allocation behavior (`calloc`/`free`, `R_chk_calloc`, etc.).
- OpenCL kernels cannot rely on host runtime allocators unless a compatible device-side shim exists.

### Primary observed case
- `wilcox.cl` (`rwilcox`, `cwilcox`, cache init/free paths) uses dynamic allocation.
- `rwilcox` is therefore a known high-risk linkage target in the OpenCL path.

### Other files/functions likely to show similar allocation-linked failures
- `signrank.cl` (`signrank_w` allocation via `calloc`).
- Any translated file path that depends on host allocator/runtime hooks not implemented for device code.

### Current handling
- Keep per-function wrappers with explicit CPU fallback where needed.
- Treat unresolved allocator/runtime externals as porting gaps until a device-safe shim is added.

## 2) Runtime/device failures in noncentral inversion pathways (`pnchisq`, `qnbeta`)

### Observed runtime symptoms
- `clEnqueueReadBuffer(out)` failure with `status=-5` (`CL_OUT_OF_RESOURCES`).
- Intermittent `clCreateContext` failures (vendor/runtime specific `status=-9999`).

### Why these are outliers
- These routines are iterative and branch-heavy, with repeated expensive CDF/special-function evaluations.
- In current kernels, this work is done serially per work-item, which can hit watchdog/runtime limits.

### `pnchisq` path details
- `pnchisq.cl` calls `pnchisq_raw(...)` with large iteration budgets.
- `pnchisq_raw(...)` includes long-running series loops, underflow/overflow regime switching, and repeated distribution calls.

### `qnbeta` path details
- `qnbeta.cl` inverts `pnbeta` by bracket search plus interval halving.
- Each iteration invokes `pnbeta(...)`, making total cost high in difficult regions.

### Other functions likely to trigger similar runtime/resource failures
- `qnf` (directly calls `qnbeta`).
- `qnchisq` (repeated calls to `pnchisq_raw` during inversion).
- `pnf` (can route through `pnchisq` branch logic).
- `qnt` (iterative inversion through repeated `pnt` evaluations).
- In general: noncentral quantile/CDF inversions with nested iterative calls.

## 3) Practical testing guidance

- Use small `n` for linkage/runtime smoke tests.
- Use one function per kernel to isolate failures.
- Run with `fallback = FALSE` when you need hard OpenCL errors surfaced.
- If runtime state appears poisoned (context errors), restart R/OpenCL session before rerun.

## 4) Scope and intent

These are known limitations of the current OpenCL translation/runtime integration:
- host-style dynamic allocation assumptions in device code, and
- heavy iterative noncentral inversion routines under GPU runtime constraints.

When extending coverage, treat similar code structures as high-risk until validated.
