# CRAN submission comments — nmathopencl 0.8.4

Patch release following CRAN **0.8.3**.

## Summary

* **Configure:** Removed Rcpp header probing / Function.h workaround tooling
  (`tools/rcpp_include.R`, `tools/patch_rcpp_function_h.R`,
  `glmbayes_getRegisteredNamespace` shim). Builds use standard **`LinkingTo:
  Rcpp`**.

* **`Suggests`:** Removed **`glmbayes`** while that package is off CRAN.

* **`.Rbuildignore`:** Added **`^\.cursor$`** (hidden directory NOTE).

No other functional or API changes.

## Test environments

- Maintainer: Windows 11, R 4.6.0, OpenCL (NVIDIA).
- Optional OpenCL: CPU fallbacks via 'stats' when OpenCL is absent at compile
  time; GPU tests are skipped on CRAN (`skip_on_cran()`).

---
_This file is listed in `.Rbuildignore` and is not included in the
built source tarball. Paste into the CRAN submission "Optional comments"
field at https://cran.r-project.org/submit.html_
