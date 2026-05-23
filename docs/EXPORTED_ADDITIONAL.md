# **nmathopencl**-only core exports (non–stats-mirror, non–**`glmbayes`**-shared)

**Scope:** **`export()`** / **`exportS3method()`** symbols that are **both**

1. **not** catalogued in **`docs/EXPORTED_MATH_STATS_MIRRORS.md`** (**`d*`/`p*`/`q*`/`r*`** mirrors, specials, …), **and**
2. **not** among the **verbatim duplicate** **`export`** names shared with **`glmbayes`** (see **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`**).

Those **14** shared identifiers (**`has_opencl`**, **`load_kernel_source`**, **`load_kernel_library`**, **`gpu_names`**, **`get_opencl_core_count`**, **`verify_opencl_runtime`**, **`diagnose_glmbayes`**, **`detect_*`**, **`check_runtime_env`**, **`add_to_path_*`**, …) are **intentionally omitted** here—they are documented for cross-package refactors in **`R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** and in **`.Rd`** (e.g. **`?gpu_diagnostics`**, **`?load_kernel_library`**). You still **call** them when using **`nmathopencl`**, but **this** file is reserved for APIs **unique** to this maintainer/story (device cache, RDS subsets, authoring pipeline, **`R_ext`** smoke, **`S3`** printers for **kernel**/subset objects). **Pedagogical **`Ex_*`** sandbox exports** live **only** in **`docs/EXPORTED_EX_GLMBAYES.md`**.

**Authority:** Signatures and **`examples`** live in **`.Rd`**; run **`devtools::document()`** after **`@export`** edits.

**Sandbox `Ex_*`:** **`docs/EXPORTED_EX_GLMBAYES.md`** (full maintainer triples + quick index)—**not** duplicated below.

*(Ignore **`docs/articles/`**, **`reference/`**, …—**`pkgdown`** artefacts.)*

---

## 1 · **`glmbayes`**-shared helpers (not duplicated here)

Use this **only** as a **workflow breadcrumb**—for **Brief / Why / Details** prose on **`has_opencl()`**, **`verify_opencl_runtime()`**, diagnostics, **`load_kernel_*`**, PATH utilities, etc., see **`docs/R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`** plus the relevant **`.Rd`** topics.

Typical order when **debugging** **`nmathopencl`** GPU paths: **`has_opencl()`** → **`verify_opencl_runtime()`** → **`detect_environment_and_gpus()`** / **`detect_compute_runtimes()`** → **`check_runtime_env()`** → **`diagnose_glmbayes()`**; use **`load_kernel_source` / `load_kernel_library`** when you need raw **`.cl`** strings from **`inst/cl`**. **RDS-aware** subset loading (**`load_library_for_kernel`**, **§3**) **builds on** the same kernel text but is **peculiar to **`nmathopencl`**** and **is** documented below.

---

## 2 · **`nmathopencl`** device cache & precision (**not** verbatim **`glmbayes`** exports)

### `opencl_device_info(force = FALSE, details = FALSE)`

**Brief.** Prints **cached OpenCL device/driver** metadata (optional **force** re-probe / **details** verbosity).

**Why nmathopencl (vs `openclport`).** Amortises expensive device queries across **`*_opencl`** calls inside this package; **`openclport`** has no parallel runtime cache surface.

**Details.** Use after shared diagnostics prove OpenCL is present but kernels misbehave (platform selection, **`clBuildProgram`** failures). Behaviour is tied to **`nmathopencl`** **`C++`** caching—see **`.Rd`** for return/print contract.

### `opencl_fp64_available(force = FALSE)`

**Brief.** **Boolean** probe (cached) whether **double-precision** (**`cl_khr_fp64`**) works on the chosen device.

**Why nmathopencl (vs `openclport`).** Many **`nmath`** shims target **fp64**; this is a **`nmathopencl`**-specific guardrail absent from the **`glmbayes`** intersect list.

**Details.** Pair with **`OPENCL.cl`** / kernel extension docs. **`?opencl_fp64_available`** carries exact semantics.

### `opencl_reset_device_selection()`

**Brief.** Clears **package-local** device / precision cache so the next **`opencl_*`** probe starts clean.

**Why nmathopencl (vs `openclport`).** Only meaningful where **`nmathopencl`** persists device choice in **`C++`** between **R** calls.

**Details.** Use after driver reinstalls, ICD changes, or A/B GPU tests in one **R** session.

---

## 3 · RDS-backed library subsets (**`nmathopencl`** story)

### `load_library_for_kernel(kernel_path, library_dir, depends_tag = "all_depends", index = NULL)`

**Brief.** Reads a launcher **`.cl`**’s **`@{depends_tag}`** stem list, walks **`kernel_dependency_index.rds`**, concatenates transitive library sources in **load order**.

**Why nmathopencl (vs `openclport`).** **Runtime** subsetting for fat **`inst/cl/nmath`** installs; **`openclport`** focuses on **generating** annotated sources, not shipping this **RDS** consumer.

**Details.** Pass **`index`** to skip repeated **`readRDS`**. **`warning`** when **`opencl_known_failures.json`** fires. Returns **`nmathopencl_concatenated_lib`** (**`print`** §5). **`?load_library_for_kernel`** has runnable examples.

### `extract_library_subset(kernel_paths, library_dir, ...)`

**Brief.** **Bulk** union of subset dependencies across many launchers plus per-kernel attribution metadata.

**Why nmathopencl (vs `openclport`).** Batch/CI flows for **`nmathopencl`**; not part of **`openclport`**’s exported **R** surface.

**Details.** Often follows **`attach_cross_library_tags`**. Full argument list in **`.Rd`**.

---

## 4 · Maintainer pipeline: tags, indices, offline sort

### `attach_kernel_dependency_tags(library_dir, dry_run = FALSE)`

**Brief.** Topologically sorts **one** annotated library tree and **optionally rewrites** **`//@load_order`**, **`//@all_depends`**, **`//@all_depends_count`** on each **`.cl`**.

**Why nmathopencl (vs `openclport`).** **`nmathopencl`** **exports** the maintainer entry point bound to **`inst/cl`** release practice; **`openclport`** carries reference logic, not this **RdS**-indexed product.

**Details.** Failure payload includes **`cycles`**. Internals: **`docs/UNEXPORTED_HELPERS.md`**. **`print`** §5.

### `write_kernel_dependency_index(library_dir = NULL, tags = NULL, output_path = NULL, write = TRUE, verbose = FALSE)`

**Brief.** Writes **`kernel_dependency_index.{rds,tsv}`** used by **§3** loaders.

**Why nmathopencl (vs `openclport`).** The **version-1** RDS schema is part of **`nmathopencl`**’s **shipping** **`inst/cl`** contract.

**Details.** Can re-run **`attach_kernel_dependency_tags`** internally when **`tags`** is **`NULL`**. Regenerate after **`@depends`** churn.

### `stage_kernel_dependency_sort(library_dir, output_dir, overwrite = FALSE)`

**Brief.** **Offline** copy-out: **sorted**/ **unresolved**/ **CSV** reports—**never** mutates **`library_dir`**.

**Why nmathopencl (vs `openclport`).** QA diffs for **`nmathopencl`** maintainers; no **`openclport`** twin export.

**Details.** Same sort core as **`attach_*`**, safer for **before/after** cycle surgery.

### `attach_cross_library_tags(kernel_paths, library_dir, depends_tag, index = NULL, dry_run = FALSE)`

**Brief.** Expands cross-library **`@{depends_tag}`** (e.g. **`depends_nmath`**) into **`@all_depends_*`** annotations on launcher **`.cl`** files.

**Why nmathopencl (vs `openclport`).** **`inst/cl/src`** launchers depend on **`cl/nmath`**; this **bridge** is **`nmathopencl`**-specific.

**Details.** **`?attach_cross_library_tags`** example (**`readRDS`** + **`list.files`**).

---

## 5 · **`S3`** printers (**`nmathopencl`** objects)

### `print.opencl_dependency_tags(x, max_rows = 50, ...)`

**Brief.** Pretty **`attach_kernel_dependency_tags`** results (success tables or **failure** **`cycles`** / **`unresolved`**).

**Why nmathopencl (vs `openclport`).** Tied to **`nmathopencl`** tagging workflow only.

**Details.** Tune **`max_rows`** for long cycle listings.

### `print.nmathopencl_concatenated_lib(x, ...)`

**Brief.** Summarises **`load_library_for_kernel`** (**and whole-library loader** subclass) objects—stems, sizes, metadata—without dumping full sources.

**Why nmathopencl (vs `openclport`).** Class is defined for **§3**/**RDS** flows here.

**Details.** Whole-library concatenation may come from **shared** **`load_kernel_library`** (**§1**) or **`load_library_for_kernel`** (**§3**).

### `print.nmathopencl_lib_extract_df(x, ...)`

**Brief.** **`data.frame`** view for **`extract_library_subset()`** outputs.

**Why nmathopencl (vs `openclport`).** **`nmathopencl`** batch subset UX.

**Details.** **`?kernel_lib_subset_printing`** if linked from **`.Rd`**.

---

## 6 · **`R_ext`** linkage smoke (**`nmathopencl`**)

### `r_check_stack_opencl()`

**Brief.** Compiled smoke for **`R_CheckStack`** bridging used in **OpenCL**/**Rmath** translators.

**Why nmathopencl (vs `openclport`).** **`nmathopencl`** **`src/`** contract; **`openclport`** owns no **`R_ext`** suite.

**Details.** **`?rext_utils_opencl`**.

### `r_check_user_interrupt_opencl()`

**Brief.** Smoke for **`R_CheckUserInterrupt`** pathways in long GPU kernels.

**Why nmathopencl (vs `openclport`).** Same as **`r_check_stack_opencl`**.

**Details.** **`?rext_utils_opencl`**.

---

## Maintainer sync

1. **`devtools::document()`** on **`@export`** changes.
2. **This file:** only **non-mirror** exports **not** in **`R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`**.
3. **`R_FUNCTIONS_SHARED_WITH_GLMBAYES.md`:** stays the matrix for **`glmbayes`** duplicate names.
4. **`EXPORTED_MATH_STATS_MIRRORS.md`:** distribution mirrors only.
5. **`EXPORTED_EX_GLMBAYES.md`:** canonical **`Ex_*`** / **`print.Ex_glmbfamfunc`** narrative—**do not** duplicate here.
