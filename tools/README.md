# `tools/` (**nmathopencl**)

Maintainer helpers kept in the repository only (not installed with the package; see **`.Rbuildignore`**).

Native builds use standard **`LinkingTo: Rcpp`** via **`configure`** / **`configure.win`**
(OpenCL detection only; no custom Rcpp header probing).

## OpenCL/mathlib maintenance (canonical location **`openclport`**)

Scripts that regenerated **`inst/cl/nmath`**, refreshed **`@depends_nmath`** /
**`@all_depends_nmath`** tags, or maintained the **`ex_glmbayes`** nmath subset live in
the **`openclport`** checkout under **`nmathtools/`**:

- `port_inst_cl_nmath_from_src.R`
- `refresh_src_kernel_nmath_tags.R`
- `seed_src_kernel_depends_nmath.R`
- `refresh_ex_glmbayes_nmath_subset.R`
- `build_ext_include_candidate_cls.R` (experimental)

Typical run (sibling clones `.../openclport` and `.../nmathopencl`):

```sh
Rscript ../openclport/nmathtools/port_inst_cl_nmath_from_src.R
```

Or set **`NMATHOPENCL_ROOT`** / **`OPENCLPORT_ROOT`** and call **`Rscript`** with an
absolute path to the script.

For optional Unicode-to-ASCII doc cleanup, see **`openclport/scripts/normalize_prose_ascii.R`**
(pass **`nmathopencl`** root as the first argument, or **`OPENCLPACKAGE_ROOT`**).
