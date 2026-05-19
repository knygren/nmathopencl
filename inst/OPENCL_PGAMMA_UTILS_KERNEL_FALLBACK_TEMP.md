# Temporary CPU fallback defaults (`pgamma_utils.cl` subgraph)

Some OpenCL stacks reject or warn heavily on **`double`** literals and overloads pulled in via
`inst/cl/nmath/pgamma_utils.cl` (coefficient tables ported from **`pgamma.c`**). Until **`cl_khr_fp64`**
and related toolchain issues are fixed consistently, many exported wrappers whose programs stitch any
kernel whose `@all_depends_nmath` includes `pgamma_utils` still default to **`fallback = TRUE`**: OpenCL is
still attempted first when `has_opencl()` is true, but **`clBuildProgram` / enqueue failures return
CPU results instead of throwing** (and stay **silent** while **`verbose = FALSE`**).

**Debugging note:** Density wrappers **`d*_opencl`** affected by this subgraph intentionally default **`fallback = FALSE`** again so OpenCL build/runtime failures surface clearly. Pass **`fallback = TRUE`** on densities only if silent CPU recovery is desirable.

Revert the remaining temporary defaults once device builds succeed without narrowing fp64 literals or ambiguous builtins.

## `inst/cl/src/*` entry kernels listing `pgamma_utils` in `@all_depends_nmath`

The following **`_kernel.cl`** files declare `pgamma_utils` in **`// @all_depends_nmath:`** (canonical
locations under **`inst/cl/src/`**, sorted):

`dbinom_kernel.cl`, `dbinom_raw_kernel.cl`, `dbeta_kernel.cl`, `dchisq_kernel.cl`,
`dgamma_kernel.cl`, `dgeom_kernel.cl`, `dhyper_kernel.cl`, `dnchisq_kernel.cl`,
`dnbeta_kernel.cl`, `dnbinom_kernel.cl`, `dnbinom_mu_kernel.cl`, `dnf_kernel.cl`,
`dnt_kernel.cl`, `dpois_kernel.cl`, `dpois_raw_kernel.cl`, `dt_kernel.cl`,
`df_kernel.cl`, `lgamma1p_kernel.cl`, `log1pmx_kernel.cl`, `logspace_add_kernel.cl`,
`logspace_sub_kernel.cl`, `logspace_sum_kernel.cl`, `pbeta_kernel.cl`,
`pbinom_kernel.cl`, `pchisq_kernel.cl`, `pgamma_kernel.cl`, `pf_kernel.cl`,
`phyper_kernel.cl`, `pnbeta_kernel.cl`, `pnchisq_kernel.cl`, `pnf_kernel.cl`,
`pnbinom_kernel.cl`, `pnbinom_mu_kernel.cl`, `pnt_kernel.cl`, `pow1p_kernel.cl`,
`ppois_kernel.cl`, `pt_kernel.cl`, `ptukey_kernel.cl`, `qbeta_kernel.cl`,
`qchisq_kernel.cl`, `qf_kernel.cl`, `qgamma_kernel.cl`, `qnbeta_kernel.cl`,
`qnchisq_kernel.cl`, `qnf_kernel.cl`, `qnt_kernel.cl`, `qt_kernel.cl`,
`qtukey_kernel.cl`, `qweibull_kernel.cl`, `rchisq_kernel.cl`, `rf_kernel.cl`,
`rhyper_kernel.cl`, `rnchisq_kernel.cl`, `rt_kernel.cl`.

Rebuild this list anytime with repository search:

`rg -l 'pgamma_utils' inst/cl/src --glob '*_kernel*.cl'`

## Exported R wrappers: temporary **`fallback = TRUE`** default

Only wrappers that stitch the above kernel set **and** ship as user-facing **`*_opencl()`** had their
defaults changed (other **`_opencl`** entries stay **`fallback = FALSE`** unless already different;
pass **`fallback = FALSE`** explicitly when you want hard failures).

Density **`d*_opencl`** in these families default **`fallback = FALSE`** (see intro above); they are omitted from this table.

| Topic | Wrappers (`fallback = TRUE` default temporarily) |
|-------|-----------------------------------------------------|
| Rmath helpers | **`log1pmx_opencl`**, **`lgamma1p_opencl`**, **`pow1p_opencl`**, **`logspace_add_opencl`**, **`logspace_sub_opencl`**, **`logspace_sum_opencl`** |
| Beta | **`pbeta_opencl`**, **`qbeta_opencl`** |
| Binomial | **`pbinom_opencl`** |
| Chi-squared / F / t | **`pchisq_opencl`**, **`qchisq_opencl`**, **`rchisq_opencl`**; **`pf_opencl`**, **`qf_opencl`**, **`rf_opencl`**; **`pt_opencl`**, **`qt_opencl`**, **`rt_opencl`** |
| Gamma | **`qgamma_opencl`** |
| Hypergeometric | **`phyper_opencl`**, **`rhyper_opencl`** |
| Negative binomial | **`pnbinom_opencl`**, **`pnbinom_mu_opencl`** |
| Poisson | **`ppois_opencl`** |
| Studentized range | **`ptukey_opencl`**, **`qtukey_opencl`** |
| Weibull | **`qweibull_opencl`** |
