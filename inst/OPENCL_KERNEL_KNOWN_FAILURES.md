# Known OpenCL kernel / device failures

Tracked issues where the OpenCL **program fails to compile** or **hits linker-like errors**
on device (not “OpenCL unavailable”). Package examples use **`fallback = FALSE`** and must
not rely on CPU fallback to mask these.

When a wrapper is blocked, either fix the bundled kernel/program or **disable the matching
examples** (`\dontrun` / commented lines with a pointer here).

Add new rows when `R CMD check` or manual runs surface reproducible failures.

## Program build failures (device compile / link)

| Function / wrapper | Kernel (if named)               | Typical symptom                                        | Cause (current understanding)                                                                 |
|--------------------|----------------------------------|--------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `qbeta_opencl`    | `qbeta_kernel`                  | `ptxas fatal : Unresolved extern function 'Rf_lbeta'` | NVPTX/OpenCL lowers code that references `Rf_lbeta` (`lbeta` / nmath tail); symbol is host-only |
| `qgamma_opencl`   | `qgamma_kernel`                 | `ptxas fatal : Unresolved extern function 'stirlerr_cycle_free'` | Device link sees nmath Stirling/Stirlerr helpers not defined for this target |
| `qlogis_opencl`   | `qlogis_kernel`                 | `ptxas fatal : Unresolved extern function 'Rf_qlogis'` | `Rmath` maps `qlogis`→`Rf_qlogis` at some call sites while `qlogis.cl` emits `qlogis`; NVPTX linker has no matching `Rf_qlogis` |
| `qt_opencl`       | `qnt_kernel`                    | `ptxas fatal : Unresolved extern function 'Rf_qnt'` | `Rmath` maps `qnt`→`Rf_qnt`; NVPTX has no device `Rf_qnt` (host nmath symbol in device link) |
| `qunif_opencl`    | `qunif_kernel`                  | `ptxas fatal : Unresolved extern function 'Rf_qunif'` | `Rmath` maps `qunif`→`Rf_qunif`; NVPTX has no device `Rf_qunif` |

## Notes

- **Not listed:** failures when `has_opencl()` is false (`fallback` is intended for absent OpenCL / load failure paths at the discretion of each wrapper).
- **Goal:** shrink this list by refactoring kernels to inlined device-safe helpers or narrower nmath subgraphs where feasible.
- **Hypothesis:** loading or linking more of bundled nmath into the assembled OpenCL program could define additional `Rf_*` symbols currently missing at device link; not verified yet.
