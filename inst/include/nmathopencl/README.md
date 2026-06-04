# Headers for `LinkingTo: nmathopencl`

Installed as `include/nmathopencl/` when **nmathopencl** is installed. Downstream
packages that call GPU nmath from C/C++ should use the **C API**:

```cpp
#include <nmathopencl/nmathopencl_capi.h>

if (nmathopencl_has_opencl()) {
  SEXP out = nmathopencl_dnorm_opencl(x, mean, sd, give_log, parallel, verbose);
}
```

## Requirements

- **`Imports: nmathopencl, opencltools`** — DLLs must be loaded; `*_opencl` uses
  opencltools for kernel source loading at runtime.
- **`LinkingTo: nmathopencl`** — supplies `-I` for this header only.
- **No `PKG_LIBS`** for C API-only use (symbols resolve via `R_GetCCallable`).
- **`nmathopencl_api_version()`** — call for ABI compatibility checks (currently `1`).
- OpenCL SDK/system `-I` / `-lOpenCL` in your own `configure` when you compile
  GPU code paths (`USE_OPENCL`); Khronos headers are **not** bundled here.

## Kernel loading and device utilities

Use **opencltools** (`#include <opencltools/opencltools_capi.h>`), not this header.

## Regenerating

From the package root:

```bash
Rscript tools/generate_nmathopencl_capi.R
Rcpp::compileAttributes()
```

Source of truth for signatures: `src/export_wrappers.cpp` (GPU `*_opencl_cpp_export` only).
