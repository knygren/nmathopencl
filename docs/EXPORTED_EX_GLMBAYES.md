# Exported **`Ex_*`** APIs — pedagogical **`Envelope`** / **`glmbayes`** sandbox

**Scope:** **`export()`** / **`exportS3method()`** teaching wrappers in **`R/ex_glmbayes.R`** and related shards—**different** symbol names from **`glmbayes`** proper, but mirroring **`Envelope*`** / **`glmb`** workflows for **`nmathopencl`** vignettes and examples. **Not** listed in **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** (that file is **verbatim** **`NAMESPACE`** duplicates only).

**Authority:** Signatures and **`examples`** live in **`.Rd`**; run **`devtools::document()`** after **`@export`** edits.

**Shared infrastructure:** **`has_opencl()`**, **`load_kernel_*`**, diagnostics, PATH helpers, etc.—see **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** and the relevant **`.Rd`** topics (**`?gpu_diagnostics`**, **`?load_kernel_library`**, …). **`docs/EXPORTED_ADDITIONAL.md`** documents **`nmathopencl`‑only** core exports (device cache, RDS subsets, maintainer pipeline, other **`S3`** printers, **`r_check_*`**) and **does not** duplicate this sandbox.

## Quick index

| Export | Role (one line) |
|--------|-----------------|
| `Ex_EnvelopeEval` | GPU-capable **`EnvelopeEval`**-style objective evaluation |
| `Ex_EnvelopeOpt` | Small optimiser layered on envelope losses |
| `Ex_EnvelopeSize` | Grid / envelope sizing analogue of **`EnvelopeSize`** |
| `Ex_glmb_Standardize_Model` | Teaching standardisation helper mirroring **`glmb_Standardize_Model`** |
| `Ex_glmbfamfunc` | Family object analogue of **`glmbfamfunc`** (**`S3`** **`print`** registered) |

---

## `Ex_EnvelopeSize(...)`

**Brief.** Minimal **GPU-aware** **`EnvelopeSize`**-style teaching analogue.

**Why nmathopencl (vs `openclport`).** Statistical/GPU pedagogy lives in **`nmathopencl`**; **`openclport`** is porting infrastructure.

**Details.** Uses **`.Rd`** argument contract. For **environment** troubleshooting, call the **shared** **`glmbayes`** diagnostics (**`?diagnose_glmbayes`**—see **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`**), not re-documented here.

---

## `Ex_EnvelopeEval(...)`

**Brief.** **`EnvelopeEval`**-style objective evaluation with optional **OpenCL**.

**Why nmathopencl (vs `openclport`).** Same as **`Ex_EnvelopeSize`**.

**Details.** Often paired with **`system.file("cl/...")`** and **`use_opencl=TRUE`**; kernel string assembly may use **shared** **`load_kernel_*`** (**`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** + **`?load_kernel_library`**).

---

## `Ex_EnvelopeOpt(...)`

**Brief.** Small **optim** driver on **`Ex_EnvelopeEval`**-like losses.

**Why nmathopencl (vs `openclport`).** Teaching-only **`nmathopencl`** surface.

**Details.** **`?Ex_EnvelopeOpt`** for **`control`** and GPU switches.

---

## `Ex_glmb_Standardize_Model(...)`

**Brief.** Stand-alone **standardisation** helper paralleling **`glmb_Standardize_Model`** for examples.

**Why nmathopencl (vs `openclport`).** Model-prep **R** façade unrelated to **`openclport`**.

**Details.** Shares **`.Call`** tiering with **`Envelope`** examples—see **`.Rd`**.

---

## `Ex_glmbfamfunc(...)`

**Brief.** Builds **`"Ex_glmbfamfunc"`** family object for vignettes.

**Why nmathopencl (vs `openclport`).** Pedagogical **`S3`**, not port tooling.

**Details.** **`print.Ex_glmbfamfunc`** below.

---

## `print.Ex_glmbfamfunc(x, ...)`

**Brief.** Compact **`Ex_glmbfamfunc`** display.

**Why nmathopencl (vs `openclport`).** Teaching **`S3`**.

**Details.** Auto-used when printing **`Ex_*`** family objects.

---

## Maintainer sync

1. **`devtools::document()`** on **`@export`** / **`@exportS3method`** changes.
2. Keep **`docs/EXPORTED_ADDITIONAL.md`** free of **`Ex_*`** triples—this file owns the sandbox narrative.
