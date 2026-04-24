# CRAN submission comments — glmbayes 0.9.0

## Package summary

glmbayes provides iid sampling for Bayesian Generalized Linear Models
(Gaussian, Poisson, Binomial, Gamma) via accept-reject methods based on
likelihood subgradients (Nygren & Nygren, 2006). It mirrors the interface
of base R's glm() and lm(), and optionally accelerates envelope
construction via OpenCL for high-dimensional models. OpenCL is an optional
capability; the package detects its absence at build time and disables that
code path gracefully — all checks pass on platforms without OpenCL.

## Test environments

### Local (developer machine)
- Windows 11, ASUS TUF F16, GeForce RTX GPU, OpenCL installed
- R [version], glmbayes built with OpenCL enabled
- Result: 0 errors, 0 warnings, 2 notes (see Notes section)

### Win-builder
- R release: 0 errors, 0 warnings, N notes
- R devel:   0 errors, 0 warnings, N notes
- R oldrel:  0 errors, 0 warnings, N notes

### Mac-builder
- macOS release (mac.R-project.org): 0 errors, 0 warnings, N notes
- macOS devel  (mac.R-project.org): 0 errors, 0 warnings, N notes

### R-universe
- All platforms pass except wasm (WebAssembly), which is expected:
  the package includes compiled C/C++ code that is not compatible
  with the wasm toolchain.

### rhub (via rhub::rhub_check())
- linux, macos-arm64, windows, m1-san, atlas, c23,
  clang16–clang22, gcc13–gcc16, intel, lto, mkl,
  nold, noremap, ubuntu-clang, ubuntu-gcc12,
  ubuntu-release, donttest:
  0 errors, 0 warnings, N notes
  [Note: Rcpp was pre-installed manually on some rhub platforms —
  see Rcpp note below]
- valgrind, clang-asan, clang-ubsan, gcc-asan:
  0 errors, 0 warnings, N notes
- rchk: [describe outcome and explain here]

### GPU / OpenCL on Linux (Vast.ai virtual machine)
- Ubuntu [version], OpenCL enabled, R [version]
- Confirms OpenCL code path builds and runs correctly outside Windows
- Result: 0 errors, 0 warnings, N notes

## Notes

### Note 1: New submission
This is the first submission of glmbayes to CRAN.

### Note 2: [Rcpp versioning note]
[Your explanation here — e.g. whether this is a known upstream issue,
whether it affects functionality, and any relevant Rcpp version details]

### Note 3: [New note you mentioned]
[Explanation here]

### Note on rchk
[rchk checks for PROTECT issues in C code. Describe what rchk flagged,
whether it is a false positive, and what you did to investigate or
mitigate it. If the flag is in Rcpp-generated code rather than your
own C, say so explicitly.]

---
_This file is listed in `.Rbuildignore` and is not included in the built
source tarball. When submitting, paste the content above into the
"Optional comments" field on the CRAN submission form at
https://cran.r-project.org/submit.html._