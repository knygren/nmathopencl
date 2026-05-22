# `tools/` ( **`nmathopencl`** )

Maintainer helpers that stay **inside this repository** only (not installed with the package; see **`.Rbuildignore`**).

## OpenCL/mathlib maintenance (canonical location **`openclport`**)

Scripts that regenerated **`inst/cl/nmath`**, refreshed **`@depends_nmath`** / **`@all_depends_nmath`** tags, or maintained the **`ex_glmbayes`** nmath subset now live in the **`openclport`** checkout under **`nmathtools/`**:

- `port_inst_cl_nmath_from_src.R`
- `refresh_src_kernel_nmath_tags.R`
- `seed_src_kernel_depends_nmath.R`
- `refresh_ex_glmbayes_nmath_subset.R`
- `build_ext_include_candidate_cls.R` (experimental)

Typical run (sibling clones `.../openclport` and `.../nmathopencl`):

```sh
Rscript ../openclport/nmathtools/port_inst_cl_nmath_from_src.R
```

Or set **`NMATHOPENCL_ROOT`** / **`OPENCLPORT_ROOT`** and call **`Rscript`** with an absolute path to the script.

## Other scripts in this directory

- **`patch_rcpp_function_h.R`**, **`rcpp_include.R`** — native build / **Rcpp** tooling for this package’s DLL (workarounds for select **R** / **Rcpp** pairings around the 4.6 line), not OpenCL port orchestration.

For optional Unicode-to-ASCII doc cleanup, see **`openclport/scripts/normalize_prose_ascii.R`** (pass **`nmathopencl`** root as the first argument, or **`OPENCLPACKAGE_ROOT`**).
