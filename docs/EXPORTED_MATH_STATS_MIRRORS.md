# Exported R functions mirroring **stats** / **math** (CPU) behavior

**Scope:** **User-facing** exports only—the **`*_opencl`** (and related) maths façade names **`export(...)`’d** from **`nmathopencl`** and wired from hand‑authored **`R/*_opencl.R`** (and neighbouring **`R/`** shards listed in the source map).

**Relationship to `NAMESPACE`:** Every name below matches an **`export()`** line; keep **`NAMESPACE`** current with **`devtools::document()`** when **`@export`** tags change.  
**Complement:** **`docs/EXPORTED_ADDITIONAL.md`** documents **non‑mirror** **`export()`** names (**`nmathopencl`‑specific** device cache, RDS subset loaders, maintainer **`attach_*` / `write_*`**, **`r_check_*`**, **`S3`** printers for **kernel**/subset objects), **excluding** the **verbatim** shared **`export()`** names listed in **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** (those use **`R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** + **`.Rd`**). **Pedagogical **`Ex_*`** exports** (**`docs/EXPORTED_EX_GLMBAYES.md`**) are **out of scope** for **`EXPORTED_ADDITIONAL`**.

---

## Source map: **`R/*.R`** file → façade family

| `R/` file | Exported **`*_opencl` / maths mirror** façade(s) |
|-----------|--------------------------------------------------|
| `bessel_opencl.R` | `besselI_opencl`, `besselJ_opencl`, `besselK_opencl`, `besselY_opencl` |
| `beta_opencl.R` | `dbeta_*`, `dnbeta_*`, `pbeta_opencl`, `qbeta_opencl`, `rbeta_opencl` |
| `binomial_opencl.R` | `dbinom_raw_opencl`, `dbinom_opencl`, `pbinom_opencl`, `qbinom_opencl`, `rbinom_opencl` |
| `cauchy_opencl.R` | `dcauchy_opencl`, `pcauchy_opencl`, `qcauchy_opencl`, `rcauchy_opencl` |
| `chisq_opencl.R` | `dchisq_*`, `pchisq_*`, `qchisq_*`, `rchisq_opencl` (**no** exported `rnchisq_opencl`; non‑central draws use **`rchisq_opencl`**) |
| `exponential_opencl.R` | `dexp_*`, `pexp_*`, `qexp_*`, `rexp_opencl` |
| `f_opencl.R` | `df_*`, `pf_*`, `qf_*`, `rf_opencl` |
| `gamma_opencl.R` | `dgamma_*`, `pgamma_*`, `qgamma_*`, `rgamma_opencl` |
| `geometric_opencl.R` | `dgeom_*`, `pgeom_*`, `qgeom_*`, `rgeom_opencl` |
| `hypergeometric_opencl.R` | `dhyper_*`, `phyper_*`, `qhyper_*`, `rhyper_opencl` |
| `lnorm_opencl.R` | `dlnorm_*`, `plnorm_*`, `qlnorm_*`, `rlnorm_opencl` |
| `logistic_opencl.R` | `dlogis_*`, `plogis_*`, `qlogis_*`, `rlogis_opencl` |
| `math_support_opencl.R` | `imax2_opencl`, `imin2_opencl`, `fmax2_opencl`, `fmin2_opencl`, `sign_opencl`, `fprec_opencl`, `fround_opencl`, `fsign_opencl`, `ftrunc_opencl` |
| `multinomial_opencl.R` | `rmultinom_opencl` |
| `negative_binomial_opencl.R` | `dnbinom_*`, `pnbinom_*`, `qnbinom_*`, `rnbinom_opencl`, **`_mu`** variants |
| `normal_opencl.R` | `dnorm_*`, `pnorm_*`, `qnorm_*`, `rnorm_opencl` |
| `poisson_opencl.R` | `dpois_raw_opencl`, `dpois_*`, `ppois_*`, `qpois_*`, `rpois_opencl` |
| `rmath_runtime_opencl.R` | `r_pow_opencl`, `r_pow_di_opencl`, `log1pmx_*`, `log1pexp_*`, `log1mexp_*`, `lgamma1p_opencl`, `pow1p_*`, `logspace_{add,sub,sum}_opencl` |
| `rng_core_opencl.R` | `norm_rand_opencl`, `unif_rand_opencl`, `r_unif_index_opencl`, `exp_rand_opencl` |
| `rwilcox_opencl.R` | `dwilcox_*`, `pwilcox_*`, `qwilcox_*`, `rwilcox_opencl` |
| `signrank_opencl.R` | `dsignrank_*`, `psignrank_*`, `qsignrank_*`, `rsignrank_opencl` |
| `special_opencl.R` | `gammafn_*`, `lgammafn_*`, `{di,tetra,penta}gamma_*`, `psigamma_*`, `beta_opencl`, `lbeta_*`, `choose_opencl`, `lchoose_opencl` |
| `t_opencl.R` | `dt_*`, `pt_*`, `qt_*`, `rt_opencl` |
| `tukey_opencl.R` | `ptukey_*`, `qtukey_*` |
| `uniform_opencl.R` | `dunif_*`, `punif_*`, `qunif_*`, `runif_opencl` |
| `weibull_opencl.R` | `dweibull_*`, `pweibull_*`, `qweibull_*`, `rweibull_opencl` |
*`…` rows abbreviate repetitive argument lists unchanged across `d*`/`p*`/`q*` families.*  

---

## Legend

| Host analogue | Notes |
|---------------|-------|
| **`stats::`** | `d*` density, `p*` CDF, `q*` quantile, `r*` random |
| **`{cmath}` / nmath** | `bessel*`, `gammafn`, `lgamma*`, … |
| **`Rmath` / translators** | Raw Poisson/binomial, log1p variants, `logspace_*`, `r_pow*` |
| **Lower-level RNG exports** | Host `norm_rand` / `unif_rand` style streams (see **`?norm_rand` internals**) |

---

## Bessel & elementary specials

| Export | Typical CPU analogue |
|--------|----------------------|
| `besselI_opencl` | `besselI` |
| `besselJ_opencl` | `besselJ` |
| `besselK_opencl` | `besselK` |
| `besselY_opencl` | `besselY` |
| `beta_opencl` | Euler Beta `beta(a,b)` |
| `choose_opencl` | `choose` |
| `digamma_opencl` | `digamma` |
| `gammafn_opencl` | `gamma` (Γ) |
| `lgammafn_opencl` | `lgamma` |
| `lgamma1p_opencl` | `lgamma1p` |
| `psigamma_opencl` | `psigamma` |
| `trigamma_opencl` | `trigamma` |
| `tetragamma_opencl` | `psigamma(.., 2)` family |
| `pentagamma_opencl` | higher order polygamma analogue |
| `lbeta_opencl` | `lbeta` |
| `lchoose_opencl` | `lchoose` |
| `pow1p_opencl` | `R_pow` style `pow1p` |
| `sign_opencl` | `sign` |

---

## Rounding / extrema helpers (`f*` / `i*`)

| Export | Analogue |
|--------|----------|
| `fmax2_opencl`, `fmin2_opencl` | scalar `fmax2` / `fmin2` |
| `fprec_opencl`, `fround_opencl`, `fsign_opencl`, `ftrunc_opencl` | R `fprec`/`fround`/… |
| `imax2_opencl`, `imin2_opencl` | `imax2`/`imin2` |

---

## Stable transforms & log-sum tricks

| Export | Analogue / use |
|--------|----------------|
| `log1pmx_opencl` | `log1pmx` |
| `log1pexp_opencl` | `log1pexp` |
| `log1mexp_opencl` | `log1mexp` |
| `logspace_add_opencl` | host `logspace_add` |
| `logspace_sub_opencl` | host `logspace_sub` |
| `logspace_sum_opencl` | host `logspace_sum` |
| `r_pow_opencl` | `pow` wrapper |
| `r_pow_di_opencl` | int‑exponent power |

---

## Core RNG primitives (not `stats::rnorm` façade)

| Export | Analogue |
|--------|----------|
| `norm_rand_opencl` | `norm_rand` |
| `unif_rand_opencl` | `unif_rand` |
| `exp_rand_opencl` | `exp_rand` |
| `r_unif_index_opencl` | `R_unif_index` style indexing |

*(Higher‑level **`r*_opencl`** for standard distributions appear below.)*

---

## Continuous / discrete distributions (`d`, `p`, `q`, `r`)

Grouped by distribution family. Each row lists **R** exports registered in **`NAMESPACE`**.

### Normal

| d | p | q | r |
|---|---|---|---|
| `dnorm_opencl` | `pnorm_opencl` | `qnorm_opencl` | `rnorm_opencl` |

### Uniform

| d | p | q | r |
|---|---|---|---|
| `dunif_opencl` | `punif_opencl` | `qunif_opencl` | `runif_opencl` |

### Gamma & χ²

| d | p | q | r |
|---|---|---|---|
| `dgamma_opencl` | `pgamma_opencl` | `qgamma_opencl` | `rgamma_opencl` |
| `dchisq_opencl` | `pchisq_opencl` | `qchisq_opencl` | `rchisq_opencl` |

*`rchisq_opencl` covers central and non‑central χ² draws; there is **no exported** separate `rnchisq_opencl` façade.*  

### Beta (incl. non‑central density)

| d | p | q | r |
|---|---|---|---|
| `dbeta_opencl` `dnbeta_opencl` | `pbeta_opencl` | `qbeta_opencl` | `rbeta_opencl` |

### F & Student *t*

| d | p | q | r |
|---|---|---|---|
| `df_opencl` | `pf_opencl` | `qf_opencl` | `rf_opencl` |
| `dt_opencl` | `pt_opencl` | `qt_opencl` | `rt_opencl` |

### Binomial (+ raw)

| d | p | q | r |
|---|---|---|---|
| `dbinom_opencl` **`dbinom_raw_opencl`** | `pbinom_opencl` | `qbinom_opencl` | `rbinom_opencl` |

### Negative binomial (`prob` & `mu` parameterizations)

| d | p | q | r |
|---|---|---|---|
| `dnbinom_opencl` | `pnbinom_opencl` | `qnbinom_opencl` | `rnbinom_opencl` |
| `dnbinom_mu_opencl` | `pnbinom_mu_opencl` | `qnbinom_mu_opencl` | `rnbinom_mu_opencl` |

### Multinomial *(custom)*

*(only `r*` in this package)*  

| r |
|---|
| `rmultinom_opencl` |

### Poisson (+ raw density)

| d | p | q | r |
|---|---|---|---|
| `dpois_opencl` **`dpois_raw_opencl`** | `ppois_opencl` | `qpois_opencl` | `rpois_opencl` |

### Geometric / hypergeometric

| d | p | q | r |
|---|---|---|---|
| `dgeom_opencl` | `pgeom_opencl` | `qgeom_opencl` | `rgeom_opencl` |
| `dhyper_opencl` | `phyper_opencl` | `qhyper_opencl` | `rhyper_opencl` |

### Cauchy / exponential

| d | p | q | r |
|---|---|---|---|
| `dcauchy_opencl` | `pcauchy_opencl` | `qcauchy_opencl` | `rcauchy_opencl` |
| `dexp_opencl` | `pexp_opencl` | `qexp_opencl` | `rexp_opencl` |

### Log‑normal / Weibull

| d | p | q | r |
|---|---|---|---|
| `dlnorm_opencl` | `plnorm_opencl` | `qlnorm_opencl` | `rlnorm_opencl` |
| `dweibull_opencl` | `pweibull_opencl` | `qweibull_opencl` | `rweibull_opencl` |

### Logistic

| d | p | q | r |
|---|---|---|---|
| `dlogis_opencl` | `plogis_opencl` | `qlogis_opencl` | `rlogis_opencl` |

---

## Non‑central extensions & rank tests

Many **`p`/`q`** for **Wilcoxon / Tukey / sign‑rank** exist only where ported kernels landed.

### Wilcoxon rank‑sum (`stats::wilcox`)

| d | p | q | r |
|---|---|---|---|
| `dwilcox_opencl` | `pwilcox_opencl` | `qwilcox_opencl` | `rwilcox_opencl` |

### Sign rank (`stats::wilcox.signrank`)

| d | p | q | r |
|---|---|---|---|
| `dsignrank_opencl` | `psignrank_opencl` | `qsignrank_opencl` | `rsignrank_opencl` |

### Studentized range (**Tukey**)

| d | p | q | r |
|---|---|---|---|
| *(not exported‑d)* | `ptukey_opencl` | `qtukey_opencl` | *(no r‑tukey RNG)* |

---

## Maintainer sync (**user-facing** façade changes)

Whenever exported wrappers rotate (**new `R/*_opencl.R`**, signature churn, retiring kernels):

1. Run **`devtools::document()`** so **`NAMESPACE`** matches **`R/*.R`** **`@export`** tags.
2. Update the **Source map** table above for any new **`R/`** shard file.
3. Keep **`docs/EXPORTED_ADDITIONAL.md`** focused on **non-mirror**, **non–verbatim-`glmbayes`** **`export()`** workflow narrative (**no **`Ex_*`** prose**—use **`docs/EXPORTED_EX_GLMBAYES.md`**); distribution mirrors stay **here** only, and duplicate-name inventory stays in **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`**.

