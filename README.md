# nmathopencl

![License: GPL-2](https://img.shields.io/badge/license-GPL--2-blue.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/knygren/nmathopencl?label=version)

`nmathopencl` is an OpenCL port of R's Mathlib (`nmath`) — the C library
that powers the statistical and mathematical functions in R. Its primary
purpose is to serve as a **reusable backend library** for developers who want
to write GPU-accelerated R code that calls nmath functions from within their
own custom OpenCL kernels.

---

## Why does this exist?

### The problem: you want GPU acceleration, but your math is R's math

Suppose you are writing an R package that benefits from GPU computation. Your
algorithm is embarrassingly parallel — many independent evaluations, no
data dependency between them — and you want to dispatch that work to an
OpenCL device. So far, so good.

The problem arises when the computation you need to parallelize is not just
arithmetic, but statistical math: log-likelihoods that call `lgamma` or
`lbeta`, sampling routines that call `rgamma` or `rnorm`, acceptance criteria
that evaluate `pbeta` or `pnorm`. These functions exist in R and in R's C
library, but they are designed for sequential host execution. They are not
available inside an OpenCL kernel. A GPU kernel cannot call `stats::dgamma`.

Before `nmathopencl`, a developer wanting GPU-accelerated statistical math had
two options: find a third-party GPU math library and translate their algorithm
into that library's API, or port the required nmath functions themselves. Both
options are substantial engineering work, and neither produces something that
other R developers can reuse.

`nmathopencl` solves this by providing the ported sources as a **distributable
R package**. Install `nmathopencl`, and the ported OpenCL C files are available
on disk at `system.file("cl", package = "nmathopencl")`. Any R package that
lists `nmathopencl` as a dependency can find those files at runtime and include
them in its own OpenCL program builds.

---

## The canonical example: glmbayes and EnvelopeEval

The most direct illustration of how `nmathopencl` is meant to be used is
`glmbayes`. Bayesian GLM sampling via accept-reject methods requires evaluating
likelihood envelope functions for every posterior draw. This construction is
embarrassingly parallel — each candidate can be evaluated independently — but
the inner computation involves distribution functions and special functions
from nmath: `lgamma`, `lbeta`, `pgamma`, `dnorm`, and related routines.

To accelerate this step on a GPU, `glmbayes` builds an OpenCL program at
runtime that includes the relevant ported nmath sources from `nmathopencl` and
adds its own kernel logic on top. The program compilation happens once; all
subsequent envelope evaluations within a session are dispatched to the GPU.
The speedup grows with model dimension, because a larger parameter space means
more independent envelope evaluations per draw.

### EnvelopeEval: the concrete case

`EnvelopeEval()` in `glmbayes` is the function that evaluates the negative
log-likelihood and its gradients across a full grid of parameter values — the
step that feeds the rejection sampler. For a Bayesian binomial logit model
with, say, fourteen predictors, this grid can contain thousands of points, and
each point requires evaluating the binomial log-likelihood and its gradient
vector using nmath routines.

When `use_opencl = TRUE`, `EnvelopeEval` dispatches to its GPU backend
(`f2_f3_opencl`). That function assembles a complete OpenCL program at
runtime by concatenating three layers of source code:

1. A global configuration header (`OPENCL.cl`) that enables double-precision
   arithmetic and defines IEEE constants.
2. The ported nmath library sources from `nmathopencl` — the `rmath`, `nmath`,
   and `dpq` subdirectory files — which make functions like `lgamma`, `lbeta`,
   `dbinom`, and `dpois` available as device-side functions.
3. The model- and link-specific kernel (e.g. `f2_f3_binomial_logit.cl`), which
   contains the actual `__kernel` entry point and calls freely into the nmath
   layer above it.

This assembled source is compiled once by the OpenCL driver and then
dispatched as a single kernel invocation. All grid points are evaluated
simultaneously on the GPU; the results come back as the `NegLL` vector and
`cbars` gradient matrix that the rejection sampler consumes.

Without `nmathopencl`, writing `f2_f3_binomial_logit.cl` would require either
re-implementing `lgamma`, `lbeta`, and `dbinom` from scratch inside the kernel
or finding a compatible GPU math library — a significant engineering effort
that would also be package-specific and non-reusable. With `nmathopencl`, the
nmath layer is already there, annotated for dependency resolution, and
available to any package that lists `nmathopencl` as a dependency.

For a detailed walkthrough of the `EnvelopeEval` workflow — including the
full program assembly sequence, the CPU and GPU backends, and the role of the
computed values in the rejection sampler — see:

- `?EnvelopeEval` in `glmbayes`
- `example("EnvelopeEval")` for a runnable isolated demonstration
- [Chapter A10 — Accelerated EnvelopeBuild Implementation using OpenCL](https://knygren.r-universe.dev/articles/glmbayes/Chapter-A10.html)
- [Chapter 12 — Large Models: GPU Acceleration using OpenCL](https://knygren.r-universe.dev/articles/glmbayes/Chapter-12.html)

This pattern — borrow the nmath layer from `nmathopencl`, write your own
kernel logic that calls into it — is exactly what this package is designed to
enable. `glmbayes` provides the reference implementation, but the same approach
applies to any package that needs statistical math inside an OpenCL kernel.

---

## What "using nmathopencl as a backend" looks like

At the R level, the pattern is straightforward. In your package, at the point
where you assemble an OpenCL program:

```r
# Locate the nmath OpenCL source tree from the installed package
nmath_cl_dir  <- system.file("cl", package = "nmathopencl")

# Assemble your program source by combining the nmath layer with your kernel
program_source <- c(
  readLines(file.path(nmath_cl_dir, "R_ext_types",  "...")),
  readLines(file.path(nmath_cl_dir, "R_ext_runtime", "...")),
  readLines(file.path(nmath_cl_dir, "nmath", "lgamma.cl")),
  readLines(file.path(nmath_cl_dir, "nmath", "lbeta.cl")),
  readLines(file.path(nmath_cl_dir, "nmath", "pbeta.cl")),
  # ... any other nmath files your kernel needs ...
  your_custom_kernel_source   # calls lgamma(), lbeta(), pbeta() freely
)

# Build and run the program with your OpenCL framework of choice
```

Inside `your_custom_kernel_source`, functions like `lgamma`, `lbeta`,
`pbeta`, `dnorm`, `rgamma`, and the rest are available as device functions,
because the nmath sources define them as inline OpenCL C functions. You call
them exactly as you would in regular C code. The GPU handles parallelism
through the normal OpenCL work-item model.

The result is that you can write kernel logic that looks essentially identical
to what you would write in R — using the same functions, the same parameter
conventions, the same numeric behavior — but executes on the GPU.

---

## What is actually ported

The `inst/cl` directory of `nmathopencl` is the distributable library tree.
It is organized into dependency layers that mirror how R itself structures
these components:

```
inst/cl/
  R_ext_types/       — type definitions (SEXP, Rboolean, etc.)
  R_ext_runtime/     — memory, error, and I/O interface shims
  R_ext_internals/   — internal R extension definitions
  libR_shims/        — host runtime compatibility shims (R_pow, R_pow_di, etc.)
  R_shims/           — additional R API shims
  System/            — system-level OpenCL prelude
  nmath/             — the ported Mathlib sources (~137 .cl files)
  src/               — kernel entry points for the included R wrappers
```

The `nmath/` directory contains the translated sources for the following
function families:

| Category | Functions |
|----------|-----------|
| Normal | `dnorm`, `pnorm`, `qnorm`, `rnorm` |
| Uniform | `dunif`, `punif`, `qunif`, `runif` |
| Gamma | `dgamma`, `pgamma`, `qgamma`, `rgamma` |
| Beta | `dbeta`, `pbeta`, `qbeta`, `rbeta`, `lbeta` |
| Log-Normal | `dlnorm`, `plnorm`, `qlnorm`, `rlnorm` |
| Chi-squared | `dchisq`, `pchisq`, `qchisq`, `rchisq` |
| Non-central Chi-squared | `dnchisq`, `pnchisq`, `qnchisq`, `rnchisq` |
| F | `df`, `pf`, `qf` |
| Non-central F | `dnf`, `pnf`, `qnf` |
| Student t | `dt`, `pt`, `qt`, `rt` |
| Non-central t | `dnt`, `pnt`, `qnt` |
| Binomial | `dbinom`, `pbinom`, `qbinom`, `rbinom`, `dbinom_raw` |
| Negative Binomial | `dnbinom`, `pnbinom`, `qnbinom`, `rnbinom` (and `_mu` variants) |
| Poisson | `dpois`, `ppois`, `qpois`, `rpois`, `dpois_raw` |
| Exponential | `dexp`, `pexp`, `qexp`, `rexp` |
| Weibull | `dweibull`, `pweibull`, `qweibull`, `rweibull` |
| Logistic | `dlogis`, `plogis`, `qlogis`, `rlogis` |
| Cauchy | `dcauchy`, `pcauchy`, `qcauchy`, `rcauchy` |
| Geometric | `dgeom`, `pgeom`, `qgeom`, `rgeom` |
| Hypergeometric | `dhyper`, `phyper`, `qhyper`, `rhyper` |
| Non-central Beta | `dnbeta`, `pnbeta`, `qnbeta` |
| Studentized Range | `ptukey`, `qtukey` |
| Wilcoxon Rank Sum | `dwilcox`, `pwilcox`, `qwilcox`, `rwilcox` |
| Wilcoxon Signed Rank | `dsignrank`, `psignrank`, `qsignrank`, `rsignrank` |
| Multinomial | `rmultinom` |
| Gamma/special | `gammafn`, `lgammafn`, `psigamma`, `digamma`, `trigamma`, `tetragamma`, `pentagamma` |
| Beta/choose | `beta`, `lbeta`, `choose`, `lchoose` |
| Bessel | `bessel_i`, `bessel_j`, `bessel_k`, `bessel_y` (and `_ex` variants) |
| Math support | `fmax2`, `fmin2`, `imax2`, `imin2`, `sign`, `fprec`, `fround`, `fsign`, `ftrunc` |
| Runtime math | `log1pmx`, `log1pexp`, `log1mexp`, `lgamma1p`, `pow1p`, `logspace_add`, `logspace_sub`, `logspace_sum` |
| RNG core | `exp_rand`, `norm_rand`, `unif_rand` |

Each `.cl` file is the translated equivalent of the corresponding nmath `.c`
source. Where the upstream source depends on host-only R runtime behaviors
(macros, inline utility functions, type aliases), those dependencies are
satisfied by the layered shim files in the other subdirectories.

---

## Secondary feature: direct R wrappers

In addition to the ported `.cl` files, `nmathopencl` includes a set of
R-facing wrappers that call individual nmath functions as GPU kernels
directly from R:

```r
library(nmathopencl)

# Evaluate the gamma PDF at a fixed parameter set, n times in parallel
dgamma_opencl(n = 1e5, x = 2.5, shape = 3, scale = 1)

# Draw random normals on the GPU
rnorm_opencl(n = 1e6, mean = 0, sd = 1)

# Compute log-probabilities for a fixed Poisson parameter
dpois_opencl(n = 5e4, x = 3, lambda = 2.5, log = TRUE)
```

These wrappers serve two purposes. First, they are useful for **testing and
validation**: they let you verify that a particular ported function behaves
correctly before embedding it inside a larger kernel. Second, they provide a
convenient interface for cases where the entire bottleneck really is a large
batch of identical distribution evaluations — though as noted above, this is
not the primary use case the package was designed around.

Each wrapper accepts `fallback = TRUE` (default), which silently falls back
to the corresponding `stats` function if OpenCL is unavailable or fails. This
means packages that use these wrappers work correctly on machines without a
GPU — they simply lose the acceleration. Set `fallback = FALSE` if you need
hard failures rather than silent fallback.

To check OpenCL availability:

```r
has_opencl()
```

---

## What had to be refactored to make this work

Porting R's Mathlib to OpenCL C is not a mechanical find-and-replace. The
upstream nmath code was written for a C compiler with access to a full host
runtime, POSIX headers, and R's own infrastructure. OpenCL device code has
none of these. Making the port work required:

- **Dependency isolation.** Each `.cl` file specifies the other `.cl` files it
  depends on. The shim layers must be loaded in an order that satisfies all
  declarations before any definitions reference them. The package includes
  tooling for managing and validating this ordering.

- **Macro and type hygiene.** R's headers define macros like `ML_ERR_return_NAN`,
  `MATHLIB_ERROR`, `R_FINITE`, and many others. These assume a host C
  environment. The ported shim files replace them with OpenCL-compatible
  equivalents.

- **Runtime symbol replacement.** Host-only R runtime symbols —
  `R_pow`, `R_pow_di`, `R_CheckUserInterrupt`, and others — are replaced by
  inline device implementations in the `libR_shims` layer.

- **Linkage model differences.** OpenCL C's compilation model differs from
  standard C in how it handles `static inline` versus external function
  definitions. Some upstream nmath functions required linkage adjustments
  to avoid "unresolved extern" failures during GPU program build.

---

## Performance: first call versus subsequent calls

When an OpenCL program is first built — whether from `nmathopencl`'s own
wrappers or from a downstream package like `glmbayes` — the driver performs a
JIT compilation of the program source for your specific GPU hardware. This step
can take several seconds for programs that include substantial portions of the
nmath library. It happens once per program, per session.

On subsequent calls, the compiled kernel is cached by the driver. The overhead
drops to kernel dispatch and buffer transfer costs, which for large batches are
small relative to the computation.

The practical takeaway: build your OpenCL programs once and reuse them across
calls. Packages like `glmbayes` do this by caching the compiled program state
for the duration of a session. If you build your own package on `nmathopencl`,
the same strategy applies.

---

## Known limitations

The port is active and expanding. Not every ported function runs on every GPU
stack without caveats. The two main limitation classes are:

### Host-runtime allocation dependencies

Some nmath routines maintain dynamic allocation caches that assume a host C
runtime. These cannot be trivially shimmed for GPU device code:

- **Wilcoxon rank sum / signed rank** (`wilcox.cl`, `signrank.cl`): both
  routines allocate and cache coefficient arrays using `calloc`/`free` or
  `R_chk_calloc`. These patterns have no direct GPU equivalent. The `.cl`
  sources are included in the library tree but result in link failures when
  used directly as GPU kernels without a device-side allocator solution. CPU
  fallback works correctly.

- **Bessel functions** (`bessel_i.cl` etc.): upstream code uses `R_alloc`
  for temporary workspace. A shim returning a null pointer is in place but
  insufficient for production use; the runtime fails when the workspace is
  dereferenced.

### Resource-intensive iterative routines

Several noncentral quantile and CDF inversion routines involve deep iterative
loops with nested distribution calls. On some GPU stacks, these hit driver
watchdog limits or register pressure:

- `qf`, `qnbeta`, `qnchisq`, `qnt`, `pnf` in some parameter regions

These functions work correctly via the CPU fallback path. Whether they run
successfully as GPU kernels depends on the hardware and driver.

### Minimal program assembly

The current kernel runner assembles a conservative superset of source files
for each kernel call. A planned dependency-analysis layer will allow building
only the minimal set of source fragments actually needed by a given kernel,
which will reduce first-call compilation time.

---

## Installation

```r
install.packages("nmathopencl",
                 repos = c("https://cloud.r-project.org",
                           "https://knygren.r-universe.dev"))
```

OpenCL support requires a GPU with an installed OpenCL runtime (NVIDIA CUDA,
AMD ROCm/OpenCL, Intel OpenCL, or Apple Metal via OpenCL compatibility). The
package installs and functions without a GPU; the ported `.cl` files are
available regardless, and all R wrappers fall back to CPU computation
automatically if OpenCL is unavailable.

---

## Future plans

- **Minimal program assembly.** Dependency analysis to include only the
  source files actually required for each kernel, reducing JIT compilation
  cost on first call.
- **Vectorized parameter API.** Allow passing a vector of distinct parameter
  values to a single kernel dispatch, enabling more general parallelism
  patterns in the R wrappers.
- **Rescue of allocation-dependent families.** Device-side allocator shims
  or algorithmic rework for Wilcoxon and Bessel paths.
- **Broader numeric validation.** Systematic accuracy testing across
  distributions and parameter regions.
- **Additional nmath coverage.** Remaining nmath functions not yet ported.

---

## References

Nygren, K.N. and Nygren, Å. (2006), Likelihood Subgradient Densities. *Journal
of the American Statistical Association*, 101, 1144–1156.
DOI: [10.1198/016214506000000357](https://doi.org/10.1198/016214506000000357)
