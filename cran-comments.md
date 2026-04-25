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
- R version 4.6.0 RC (2026-04-22 r89945 ucrt), glmbayes built with OpenCL enabled
- Rcpp 1.1.1-1
- Command: `devtools::check(vignettes = TRUE, args = "--as-cran", remote = TRUE, manual = TRUE)`

- 0 errors, 0 warnings, 3 notes

  1. New submission (see Notes)
  2. Rcpp workaround (see Notes)
  3. Long-running examples on OpenCL-enabled machine (see Notes)
   
### Win-builder

- R release 
    -R version 4.6.0 RC (2026-04-22 r89945 ucrt)
    -Rcpp 1.1.1-1    
    -0 errors, 0 warnings, 2 notes

- R-devel   
    -4.6.0 RC (2026-04-20 r89921 ucrt)
    -Rcpp 1.1.1-1    
    -0 errors, 0 warnings, 2 notes

- R-oldrelease 
    -R version 4.5.3 (2026-03-11 ucrt)
    -Rcpp 1.1.1    
    -0 errors, 0 warnings, 3 notes


  1. New submission (see Notes)
  2. Rcpp workaround (see Notes)
  3. Long-running non-OpenCL (see Notes - oldrelease only)

### Mac-builder

- macOS release (mac.R-project.org)
    - R version 4.6.0 (svn r89674)
    - Build Profile reported by macbuilder: r-devel-macosx-arm64
    - Platform: aarch64-apple-darwin23
    - Rcpp 1.1.1-1.1 (configure log prints normalized form `1.1.1.1.1`)
    - 1 error, 0 warnings, 0 notes
    - Install failed at compile time in `Rcpp/Function.h` with:
      `error: use of undeclared identifier 'R_getRegisteredNamespace'`

- macOS devel (mac.R-project.org)
    - R version 4.6.0 (svn r89674)
    - Build Profile reported by macbuilder: r-devel-macosx-arm64
    - Platform: aarch64-apple-darwin23
    - Rcpp 1.1.1-1.1 (configure log prints normalized form `1.1.1.1.1`)
    - 1 error, 0 warnings, 0 notes
    - Install failed at compile time in `Rcpp/Function.h` with:
      `error: use of undeclared identifier 'R_getRegisteredNamespace'`

The attempted macOS build resolves Rcpp from CRAN binaries for arm64 (`Rcpp 1.1.1-1.1`).
The corresponding CRAN Rcpp arm64 checks run on newer patched R snapshots (e.g. r89960), while
the current winbuilder/mac-builder environment reports `R 4.6.0 (svn r89674)`, i.e. below the
`r89746` compatibility cutoff for this Rcpp transition. Once the builder image catches up to the
current CRAN release snapshot level, this package is expected to build without this error.

### R-universe
- All platforms pass except wasm (WebAssembly), which is expected:
  the package includes compiled C/C++ code that is not compatible
  with the wasm toolchain.
-r-universe seems to source Rcpp from github repository

### rhub (via rhub::rhub_check())

**Platforms with regular checks:**

| Platform              | R version (svn)   | Rcpp version | E/W/N        |
|-----------------------|-------------------|--------------|--------------|
| atlas                 | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| c23*                  | R 4.6.0 (r89623)  | 1.1.1        | 0/0/1 NOTE   |
| clang16*              | R 4.6.0 (r89629)  | 1.1.1        | 0/0/1 NOTE   |
| clang17*              | R 4.6.0 (r89629)  | 1.1.1        | 0/0/2 NOTEs  |
| clang18*              | R 4.6.0 (r89623)  | 1.1.1        | 0/0/2 NOTEs  |
| clang19*              | R 4.6.0 (r89629)  | 1.1.1        | 0/0/2 NOTEs  |
| clang20*              | R 4.6.0 (r89623)  | 1.1.1        | 0/0/2 NOTEs  |
| clang21               | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/2 NOTEs  |
| clang22               | R 4.7.0 (r89950)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| donttest              | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| gcc13*                | R 4.6.0 (r89629)  | 1.1.1        | 0/0/1 NOTE   |
| gcc14*                | R 4.6.0 (r89629)  | 1.1.1        | 0/0/1 NOTE   |
| gcc15*                | R 4.6.0 (r89629)  | 1.1.1        | 0/0/1 NOTE   |
| gcc16                 | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| intel*                | R 4.6.0 (r89439)  | 1.1.1        | 0/0/1 NOTE   |
| linux (R-devel)       | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| lto                   | R 4.5.3 (r89597)  | 1.1.1.1      | 0/0/1 NOTE   |
| m1-san (R-devel)      | R 4.6.0 (r89961)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| macos-arm64 (R-devel) | R 4.6.0 (r89961)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| mkl                   | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| nold                  | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| noremap*              | R 4.6.0 (r89623)  | 1.1.1        | 0/0/1 NOTE   |
| ubuntu-clang          | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| ubuntu-gcc12          | R 4.7.0 (r89874)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| ubuntu-next           | R 4.6.0 (r89955)  | 1.1.1-1      | 0/0/1 NOTE   |
| ubuntu-release        | R 4.5.3 (r89597)  | 1.1.1.1      | 0/0/1 NOTE   |
| windows (R-devel)     | R 4.7.0 (r89955)  | 1.1.1.1      | 0/0/1 NOTE   |

`*` Platforms where R/Rcpp version inconsistencies prevent installation of 
Rcpp 1.1.1-1 or later. Rcpp 1.1.1 installs correctly on these platforms. 
The dual Imports/Suggests listing of Rcpp in the DESCRIPTION
handles this boundary — see Notes. The boundary appears to be r89746 
(i.e., R 4.6.0 below r89746 requires Rcpp 1.1.1 instead of Rcpp 1.1.1-1 or 
later). If the R versions on these systems get updated to the release 
version or later, these should migrate to the latest CRAN Rcpp version.

**Platforms with special checks:**

| Platform    | R version (svn)   | Rcpp version | E/W/N        |
|-------------|-------------------|--------------|--------------|
| clang-asan  | R 4.7.0 (r89961)  | 1.1.1-1.1    | 0/0/2 NOTEs  |
| clang-ubsan | R 4.7.0 (r89961)  | 1.1.1-1.1    | 0/0/2 NOTEs  |
| gcc-asan    | R 4.7.0 (r89955)  | 1.1.1-1.1    | 0/0/1 NOTE   |
| valgrind    | R 4.7.0 (r89961)  | 1.1.1-1.1    | 0/0/1 NOTE   |

- rchk: [describe outcome and explain here]


### GPU / OpenCL on Linux (Vast.ai virtual machine)
- Ubuntu [version], OpenCL enabled, R [version]
- Confirms OpenCL code path builds and runs correctly outside Windows
- Result: 0 errors, 0 warnings, N notes


## Comments Related to Notes appearing on various systems

All checks produced 0 errors and 0 warnings. The following 3 notes were
observed on the local Windows machine (R 4.6.0 RC, OpenCL enabled):

### Note: **New submission** 

       Maintainer: 'Kjell Nygren <kjell.a.nygren@gmail.com>'
       New submission

   Expected for an initial CRAN submission. No action required.

### Note: Rcpp listed in both Imports and Suggests

**Background:**

The latest release for R (4.6.0) required a patch by the Rcpp team
for Rcpp to properly build and install. Updates to R 4.6.0 starting with
svn r89746 enabled the Rcpp team to introduce a fix starting with Rcpp 1.1.1-1
that allows the package to properly build and install on the newer version of R.
This fix uses R_getRegisteredNamespace (which seems to have been added by the R team
starting with svn r89746).

This fix, however, leads to incompatibility with earlier pre-release versions of 
R 4.6.0 (as noted in the macbuilder section). As a result, CRAN currently list the below 
binaries (with differing Rcpp versions across platforms).

**Current CRAN Rcpp Package source and a binary information**

Package source:	Rcpp_1.1.1-1.1.tar.gz
Windows binaries:	r-release: Rcpp_1.1.1-1.zip, r-oldrel: Rcpp_1.1.1.zip
macOS binaries:	
  r-release (arm64): Rcpp_1.1.1-1.1.tgz, r-oldrel (arm64): Rcpp_1.1.1-1.1.tgz, 
  r-release (x86_64): Rcpp_1.1.1.tgz, r-oldrel (x86_64): Rcpp_1.1.1-1.1.tg

As seen, two platforms (windows r-oldrel) and macOS r-release (x86_64)
both use the earlier Rcpp 1.1.1 and not the version consistent with the package
source (likely because of build/install failures for Rcpp 1.1.1-1.1) on those platforms.

**Implications for glmbayes**

Because the latest release version of R (4.6.0) requires Rcpp to be of version
Rcpp 1.1.1-1 or later to properly build and install, glmbayes would ideally 
ship with Rcpp (>= 1.1.1-1) in the Imports field. However, at present this would
lead to failures of installs from CRAN on (windows r-oldrel) and macOS r-release  (x86_64)
since Rcpp 1.1.1-1 or later binaries are unavailable.

To handle this, the package currently keeps Rcpp (>= 1.1.1) in the Imports fields
and Rcpp (>= 1.1.1-1) in the Suggests field. This seems to lead to the following behavior

(i) All platforms with no Rcpp or Rcpp (< 1.1.1-1) attempts CRAN installation of 
the most recent version available

(ii) Platforms where CRAN provides valid binaries (Windows and macOS) or source (Unix) 
for Rcpp (>= 1.1.1-1) attempts that installation and should succeed unless the R system
sits on a boundary between R oldrel and R 4.6.0 release.

(iii) Platforms where CRAN does not provide valid binaries for Rcpp (< 1.1.1-1)
fall back gracefully to Rcpp 1.1.1 and attempt that install (which generally succeeds for older
versions of R)

**Proposed release approach**

To ensure binaries and/or a Source tar becomes available for all platforms on CRAN and to 
remove notes for the long term, I propose the following two step release approach:

(i) Release an initial version (glmbayes 0.9.0) with Rcpp (>= 1.1.1) in the Imports field 
and Rcpp (>= 1.1.1-1) in the Suggests field

(ii) Shortly thereafter release a patched version (tentatively glmbayes 0.9.0-1)
with Rcpp (>= 1.1.1-1) in the Imports field and no Rcpp version in the Suggests field

Once both versions are available, The sources and binaries should show consistency with Rcpp 
sources and binaries as follows:

- Package Source: glmbayes 0.9.0-1
- Windows and macOS binaries with latest Rcpp version --> glmbayes 0.9.0-1 binaries
- Windows and macOS binaries with Rcpp version 1.1.1 --> glmbayes 0.9.0 binaries


### Note: **OpenCL Examples with long CPU or elapsed time**

       Examples with CPU (user + system) or elapsed time > 5s
                        user  system elapsed
       Boston_centered 150.89  16.16  105.20
       Cleveland        42.25   3.00   29.34

   Boston_centered and Cleveland are GPU/OpenCL examples where part of code is guarded by
   `has_opencl()` that does not execute on machines without OpenCL installed.
   They will not appear on CRAN check servers. These examples 
   are used on OpenCL machines to demonstrate models with many variables and observations.

### Note: **Non-OpenCL Examples with long CPU or elapsed time**

       Examples with CPU (user + system) or elapsed time > 5s
                user  system elapsed
       rlmb    12.60    0.45   10.61

This appears only on select platforms/machines. On many, this note is never
triggered as elapsed time falls below the 5-second threshold.


### Note on rchk
[rchk checks for PROTECT issues in C code. Describe what rchk flagged,
whether it is a false positive, and what you did to investigate or
mitigate it. If the flag is in Rcpp-generated code rather than your
own C, say so explicitly.]

---
_This file is listed in `.Rbuildignore` and is not included in the built
source tarball. When submitting, paste the content above into the
"Optional comments" field on the CRAN submission form at
https://cran.r-project.org/submit.html