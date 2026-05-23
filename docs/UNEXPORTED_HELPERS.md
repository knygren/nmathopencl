# Unexported **R/** helpers (beyond **Rcpp** glue)

**Scope:** Top‑level **`name <- function(...)`** definitions in **`R/*.R`** that are **not** **`export`**’d in **`NAMESPACE`**, excluding implementation plumbing that lives **only** in:

- **`R/RcppExports.R`** (**`compileAttributes`** output)
- **`R/rcpp_wrappers.R`** (**`.Call`** / **`*_cpp`** bridges to **`RcppExports`**)
- **`R/ex_glmbayes_rcpp_wrappers.R`** (**duplicate envelope** bridges for **`Ex_*`** examples; superseded lexically by **`rcpp_wrappers.R`** where duplicated)

Indented nested functions (for example **`fallback_full`** factories inside **`d*_opencl`**) are **omitted**.

**Registry:** Symbols below were reconciled with **`Rscript scripts/list_unexported_helpers.R .`** run from the package root — re‑run after large **`R/`** edits and reconcile this file.

---

## OpenCL façade validation & recycle rules

**Brief.** Centralised scalar checks and **OpenCL-vs-CPU** branching so exported **`*_opencl`** functions fail fast before **`.Call`**.

**Why nmathopencl (vs `openclport`).** This layer is tailored to **`nmathopencl`** distribution mirrors (argument shapes recycled like **`stats`**, RNG defaults, verbosity / **`fallback`**) rather than **`openclport`**, whose focus is authoring and shimming kernels between C/R source trees.

**Details.** Helpers coerce logical **flags** / **numeric** singletons (**`.validate_*`**) so compiled entry points receive well-typed **`SEXP`**-derived inputs. Stage‑specific rules for densities and CDFs enforce tail modes and **`log`** consistency before **`opencl_parallel`** encodings (**`.encode_opencl_parallel`**). **`tryCatch`** in **`.opencl_try_or_fallback`** lets user-facing wrappers surface GPU errors cleanly and drop to deterministic CPU closures when **`fallback`** is enabled.

**File:** `R/opencl_linkage_utils.R`

| Helper | Role |
|--------|------|
| `.validate_n_scalar`, `.validate_flag`, `.validate_scalar_num` | Scalar coercion / bounds for RNG and utilities |
| `.validate_p_stage1_tails`, `.validate_d_stage1_log`, `.p_stage1_recycle_len` | Stage‑1 checks for **`p*`**/**`d*`** vector recycling |
| `.encode_opencl_parallel` | Integer encoding for parallelism toggles feeding compiled layers |
| `.opencl_try_or_fallback` | **`tryCatch`** → CPU **`fallback`** path |

---

## Concatenated library & subset introspection

**Brief.** Glue that turns **`kernel_dependency_index.rds`** and annotated **`.cl`** trees into **`nmathopencl_concatenated_lib`** artefacts, **`print`** summaries, optional known-failure warnings, and dataframe attachments for subsets.

**Why nmathopencl (vs `openclport`).** **`openclport`** tackles generic port scaffolding; **`nmathopencl`** must pair that with **`inst/cl/nmath`** library layout, the packaged **`RDS`** shard index (**`write_kernel_dependency_index`**), runtime **`extract_library_subset`** / **`load_library_for_kernel`**, and JSON-based guardrails (**`opencl_known_failures.json`**). Keeping these internals here avoids cyclic dependencies before **`openclport`** is **`Import`**-able while remaining explicit about shim vs header stems.

**Details.** **`cl_library_internals.R`** validates / filters stems against **`load_order`** and header-style exclusions, merges concatenated texts with attribution, and emits narrow warnings (**`.cl_wrap_*`**) identical to **`R CMD`** width expectations. **`kernel_known_failures.R`** parses a versioned **`jsonlite`** bundle once per session, normalises launcher paths and stems against user selections or loaded meshes, then optionally **`warning`**-s users when subsets still expose unported **Rmath/C** names. **`kernel_lib_subset_methods.R`** attaches display metadata so **`extract_library_subset`** results print like first-class summaries without bloating **`NAMESPACE`** with more **`S3`** generics.

**File:** `R/cl_library_internals.R`

| Helper | Role |
|--------|------|
| `.cl_console_text_width` | Read **`getOption("width")`**; coerce **`NA`** or values **under 40** to **80**, then clamp **[48, 72]** |
| `.cl_wrap_comma_separated` | Narrow **`message`**/**`warning`** lines for long comma‑separated lists |
| `.cl_load_index` | **`readRDS(kernel_dependency_index)`** (+ schema guard) → metadata list |
| `.cl_filter_stems` | Intersect annotated stems vs index / header‑style exclusions |
| `.cl_is_header_style_lib_stem` | Heuristic (**`kernel/lib`**, **`nmath`/header naming**) stem filter |
| `.cl_concat_result` | Assemble **`nmathopencl_concatenated_lib`** object + attributes |
| `.cl_format_unknown_stems_warning` | Copy for unknown / missing RDS stems |
| `.cl_parse_opencl_kernel_names` | Kernel name guess from **`*.cl`** basename / path conventions |
| `.cl_parse_provides_symbols` | Normalise **`@provides`** string into symbol vector |
| `.cl_print_truncated_symbols` | Elided **`cat`**‑style listing for summaries |

**File:** `R/kernel_known_failures.R`

| Helper | Role |
|--------|------|
| `.cl_read_opencl_known_failures_bundle` | Loads / caches **`opencl_known_failures.json`** (**`schema_version`** 1) |
| `.cl_maybe_warn_opencl_known_failures` | One **`warning`** path when launcher / annotate / loaded stems hit catalogued rows |
| `.cl_format_opencl_known_failure_warning` | Multi‑line **`warning`** body (narrow console + comma wrap via **`.cl_wrap_comma_separated`**) |
| `.cl_stem_normalize_set` | Trim / drop blanks; unique stem set normalization |
| `.cl_known_failure_entries_ll` | **`entries`** as robust list‑of‑rows (**`jsonlite`** DF vs list) |
| `.cl_known_failure_launcher_basenames` | Basenames from **`entry_kernels_package_relative`** |
| `.cl_known_failure_launcher_hit` | **`basename`** match on resolved kernel paths |
| `.cl_known_failure_annotate_hit` | Stem overlap with annotated subset stems |
| `.cl_known_failure_loaded_hit` | Stem overlap when loader reports **`stems_loaded`** |

*(Package cache **`.nmath_known_failures_json_cache`** (**`environment`**) holds parsed JSON—not a **`function`**.)*

**File:** `R/kernel_lib_subset_methods.R`

| Helper | Role |
|--------|------|
| `.cl_attach_extract_attrs` | Carry **`stem`**, **`n_opencl_*`**, width metadata onto extract **`data.frame`** |
| `.cl_print_stems_numbered` | Numbered stem listing for **`print.nmathopencl_lib_extract_df`** |

---

## Kernel dependency graph & authoring

**Brief.** Offline + online machinery that reads annotated **`//@`** **`@depends`** metadata on shim **`.cl`** files, topologically sorts libraries, attaches derived **`load_order`** / **`all_depends`** tags (**`attach_kernel_dependency_tags`**), emits CSV staging reports (**`stage_kernel_dependency_sort`**), and writes RDS/TSV indices consumed by **`load_library_for_kernel`**.

**Why nmathopencl (vs `openclport`).** **`openclport`** exposes portable readers/sorters; **`nmathopencl`** folds the same behaviours into **`R`** exports (**`stage_kernel_dependency_sort`**, **`attach_*`**, **`write_kernel_dependency_index`**) that must coexist with **`nmath`** shim annotations, shim classification **`//`** blocks, **`Ex_*`** teaching flows, and the packaged **`extdata`** index—without forcing an **`Imports: openclport`** edge until both packages stabilize.

**Details.** Readers normalise annotated **`//@`**/`@depends`‑style tags, perform iterative layering that repeatedly promotes stems whose prerequisites are satisfied (**`Kahn`**-style layering), annotate blocked stems with **`n`**‑hop neighbourhoods and enumerated cycle paths, optionally copy artefacts into **`sorted/`** / **`unresolved/`** staging trees, splice new **`//@`** lines after shim anchors (**`set_port_annotation`** + **`shim_inference_*`**), compute transitive dependency sets (**`DFS`**‑style closures) sorted by **`load_order`**, deduplicate cycle strings (**`cycle_path_canonical_key`** / **`cycle_min_rotation_key`**), and reuse the infix **`` `%||%` ``** for **`NULL`/`NA`** sentinel defaults beside loader **`R`** code. **`write_kernel_dependency_index`** projects labelled **`attach_*`** tag tables into a versioned RDS list (**`depends`/`all_depends`/`load_order`** plus **`stems_ordered`**) alongside a **`C++`**-friendly **`tsv`**.

### **`R/stage_kernel_dependency_sort.R`**

**Brief.** Copy-out workflow + shared sort/parser utilities consumed by **`attach_kernel_dependency_tags`**.

**Why nmathopencl (vs `openclport`).** Same lineage as **`openclport`** metadata conventions, vendored/inlined until **`attach_kernel_dependency_tags`** and **`kernel_dependency_index`** can depend on **`openclport`** as a first-class **`Import`**; **`nmathopencl`** retains hooks for **`sorted/*.cl`** artefacts used in QA diffs/vignettes.

**Details.** **`stage_kernel_dependency_sort`** is the heavyweight export: **`read_kernel_sort_records`**, **`dependency_sort_prefix`**, file copies, **`utils::write.csv`**. Ancillary parsers (**`parse_port_*`**) and **`set_port_annotation`** splice new **`//@`** lines near shim classifications to keep **`devtools::document`**-safe comment blocks. **`cycle_report_*`** collapse redundant SCC paths for actionable cycle tables surfaced in **`print.opencl_dependency_tags`** failures.

**Exported:**

| Symbol | Role |
|--------|------|
| `stage_kernel_dependency_sort` | Copies sortable kernels into **`sorted/`**, blocked ones into **`unresolved/`**, writes **`sorted_files.csv`** / **`unresolved_files.csv`** (offline staging). |

**Unexported internals:**

| Helper | Role |
|--------|------|
| `read_kernel_sort_records` | **`list.files`** **`.cl`**; **`parse_port_*`** for **`depends`**, **`includes`**, **`provides`**, **`source_origin`**, **`source_type`** |
| `dependency_sort_prefix` | **`@depends`** iterative Kahn‑style prefixes; decorate unresolved records + **`dependency_neighborhood`** diagnostics |
| `dependency_neighborhood` | Two‑ / three‑ / four‑step **`depends`** cycles & higher‑order **`depends`** sets |
| `copy_sorted_kernel_files` | Zero‑padded **`order_`** prefixed copies into **`sorted_dir`** |
| `copy_unresolved_kernel_files` | Copy blocked stems into **`unresolved_dir`** |
| `sorted_records_to_data_frame`, `unresolved_records_to_data_frame` | Tabular summaries for **`CSV`** and **`attach_kernel_dependency_tags`** failure UI |
| `transitive_depends_for_file` | DFS **`depends`** transitive closure (**`records`** keyed by stem) |
| `sort_by_order` | Order stem names by **`load_order`** index |
| `parse_port_annotation`, `parse_port_scalar_annotation` | **`// @tag`** line parsing (CSV split vs single scalar) |
| `set_port_annotation` | Strip previous **`//@ tag`**, splice new line **`after`** shim **`//`** anchor |
| `shim_inference_tag_insert_anchor` | Position after shim classification block or (**`annotation_insert_after_shim_core_metadata`**) |
| `annotation_insert_position` | Fallback insert index after **`@source_origin`** / **`@source_type`** / last **`//@`** |

**Cycle deduplication:**

| Helper | Role |
|--------|------|
| `cycle_report_from_unresolved` | Long **`cycle_path`** table (**two_step**/**three_step**/**four_step**) |
| `cycle_path_canonical_key`, `cycle_min_rotation_key` | Canonicalize loops for deduplicating cycle rows |

**Infix:**

| Helper | Role |
|--------|------|
| `` `%||%` `` | **`NULL`** / empty‑length / scalar **`NA`** → RHS fallback |

*(Uses **`escape_regex`**, **`shim_classification_tag_pattern`**, **`annotation_insert_after_shim_core_metadata`** from **`openclport_helpers.R`**.)*

### **`R/write_kernel_dependency_index.R`**

**Brief.** Persist **`kernel_dependency_index.{rds,tsv}`** next to shim libraries once **`attach_kernel_dependency_tags`** has produced consistent **`tags`**.

**Why nmathopencl (vs `openclport`).** This RDS/TSV pair is **`load_library_for_kernel`**’s authoritative **`load_order`/`depends`/`all_depends`** snapshot for packaged **`inst/cl`** kernels. **`openclport`** targets generic port manifests; **`nmathopencl`** pins **`version = 1L`** list schemas so loaders never rerun **`attach_kernel_dependency_tags`** on every **`R`** session just to reconstruct ordering metadata.

**Details.** **`write_kernel_dependency_index`** may re-run tagging when callers pass **`library_dir`** only (**`tags=NULL`** path). Helpers split CSV **`depends`/`all_depends`** strings into **`character`** **`list`** columns, reorder stems by **`load_order`**, embed **`generated_at`** / **`library_*`**, and **`writeLines`** a tab-separated companion for **`C++`** ingestion.

**Exported:**

| Symbol | Role |
|--------|------|
| `write_kernel_dependency_index` | Builds **`.rds` + `.tsv`** index from **`attach_kernel_dependency_tags`** result (or rerun **`attach_*`** when **`tags`** is **`NULL`**). |

**Unexported:**

| Helper | Role |
|--------|------|
| `kernel_dependency_index_list_from_tags` | **`tags`** **`data.frame`** → schema **`list`** (**`version`**, **`stems_ordered`**, **`load_order`**, **`depends`**, **`all_depends`**) |
| `split_kernel_depends_csv_char` | Split **`depends`/`all_depends`** CSV fields into **`character`** vectors |

---

## **`attach_kernel_dependency_tags`** implementation

**Brief.** Successful dependency sorts write **`//@load_order`**, **`//@all_depends*`**, **`//@all_depends_count`** into each resolved **`.cl`** file (**skipped when **`dry_run = TRUE`**), returning **`tags`** plus **`header_functions`** that relate header prototypes to **`c`/`cpp`** definitions via heuristic scans.

**Why nmathopencl (vs `openclport`).** **`attach_kernel_dependency_tags`** is the **`nmathopencl`** maintainer entry point tied to **`inst/cl/nmath`** payloads; **`openclport`** publishes parallel helpers for unrelated kernel repos. Hosting header-resolution here keeps **`Envelope`/`Ex_*`** vignette flows decoupled from **`openclport`** release churn while shim metadata evolves.

**Details.** Exported **`attach_kernel_dependency_tags`** calls **`read_kernel_sort_records`**, **`dependency_sort_prefix`**, **`set_port_annotation`**, **`transitive_depends_for_file`**, **`sort_by_order`**, plus **`sorted_records_to_*`**, **`unresolved_records_to_*`**, and **`cycle_report_from_unresolved`** for rich failure payloads. Lower-level parsers strip **`//`**/**`/***` comments, split heuristic C statements ending in **`;`**, track **`#define`** aliases, mine **`function_definition_*`** occurrences in **`c`/`cpp`** sources, omit **`attribute_hidden`** bodies, widen symbol candidates (**`Rf_*`** trimming), merge **`tags_df$all_depends`** back into **`header_functions`**, while **`print.opencl_dependency_tags`** prints digestible excerpts instead of full concatenations.

**File:** `R/attach_kernel_dependency_tags.R`

**Exported:**

| Symbol | Role |
|--------|------|
| `attach_kernel_dependency_tags` | Runs sort; writes **`@load_order`**, **`@all_depends`**, **`@all_depends_count`**; returns **`tags`** + **`header_functions`** |
| `print.opencl_dependency_tags` | Readable success (**`tags`** excerpts + file stats) or failure (**`unresolved`** / **`cycles`** tables) |

**Sort / annotation wiring** ( **`R/stage_kernel_dependency_sort.R`** ): `read_kernel_sort_records`, `dependency_sort_prefix`, `sorted_records_to_data_frame`, `unresolved_records_to_data_frame`, `cycle_report_from_unresolved`, `transitive_depends_for_file`, `sort_by_order`, `set_port_annotation`.

**C / header helpers** (**this file**, unexported):

| Helper | Role |
|--------|------|
| `collect_c_statements_from_lines` | **`strip_c_comments`** + semicolon‑split statement buffer (**macro / preprocessor** aware) |
| `extract_non_hidden_function_declarations` | Header heuristic: prototypes excluding **`attribute_hidden`** + noise |
| `extract_define_alias_map` | **`#define`** sym → alias map |
| `build_function_definition_index` | Symbol → **`c`/`cpp`** stem(s) via **`function_definition_names_from_text`** |
| `build_hidden_definition_name_set` | Hidden definition names (**`attribute_hidden`** in storage) |
| `definition_name_candidates` | Alternate spellings (**`Rf_` strip**) + **`define_alias`** |
| `resolve_definition_file` | Resolve **`file_defined`** stem from **`definition_index`** |
| `header_declared_non_hidden_functions` | Build **`header_functions`** table + **`all_depends`** from **`tags_df`** |
| `format_tag_csv_values` | Truncate CSV tag displays for **`print.opencl_dependency_tags`** |

**Shared parsing:** **`strip_c_comments`**, **`function_definition_names_from_text`**, **`function_definition_records_from_text`** (**`openclport_helpers.R`**).

---

## **`openclport`** authoring utilities

**Brief.** Vendored regex + comment/metadata helpers aligning **`//@`** shim annotations across **`attach_kernel_dependency_tags`**, **`stage_kernel_dependency_sort`**, and (**via transitive calls**) **`write_kernel_dependency_index`**.

**Why nmathopencl (vs `openclport`).** Until **`openclport`** is a declared **`Imports:`** companion, snippets in **`R/openclport_helpers.R`** follow upstream verbatim so **`stage_*`** and **`attach_*`** stay functional in every **`nmathopencl`** checkout; divergence should merge back consciously, not fork silently.

**Details.** Helpers recognise shim classification **`//`** lines, compute insert anchors after **`source_origin`/`depends`/`provides`** metadata, **`PCRE`**-escape **`@tag`** literals, **`vapply`**-strip **`//`** + **`/**/`** noise before heuristic **C** function-definition **`gregexpr`**, emitting **`storage`/`name`** pairs for **`attribute_hidden`** queries. **`c_identifier_pattern`/`strip_c_strings`** remain unused today but preserved for parity **`openclport`** utilities.

**File:** `R/openclport_helpers.R` *(mirror **`openclport`** when refactoring)*

| Helper | Role |
|--------|------|
| `shim_classification_tag_pattern` | Regex for shim **`//@`** classification tags |
| `annotation_insert_after_shim_core_metadata` | Highest line among core **`//@`** tags; **`annotation_insert_position`** if none matched |
| `escape_regex` | Escape **`PCRE`** metachars (used by **`parse_port_annotation`**) |
| `c_identifier_pattern` | Word‑boundary regex for a C symbol (**currently no call sites**) |
| `strip_c_strings` | Replace string literals with **`""`** (**currently no call sites**) |
| `strip_c_comments` | Line/block comment stripper (**`vapply`** state machine per line) |
| `function_definition_names_from_text` | Function names via heuristic C definition **`gregexpr`** |
| `function_definition_records_from_text` | **`storage` + `name`** **`data.frame`** from definitions |

---

## **`Ex_*`** example support

**Brief.** Internal density helper for **`Envelope*`‑style** pedagogical closures next to **`glmbayes`** teaching exports.

**Why nmathopencl (vs `openclport`).** This is **`stats`/family‑math scaffolding**, not shim port tooling; **`nmathopencl`** bundles **`Ex_*`** exports beside **`*_opencl`** primitives so GPU envelope examples ship without **`Import`**‑ing **`glmbayes`** modelling entry points.

**Details.** **`dpois2`** evaluates Poisson densities on the **`log`** scale for loss fragments referenced near the bottom of **`ex_glmbayes.R`**, avoiding name clashes with **`stats::dpois`** while keeping **`EnvelopeEval`‑like** pedagogical snippets self-contained. Exported **`Ex_*`** entry points: **`docs/EXPORTED_EX_GLMBAYES.md`**.

**File:** `R/ex_glmbayes.R`

| Helper | Role |
|--------|------|
| `dpois2` | Poisson **`log`** density helper inside **`Ex_*`** pedagogical closures (**not exported**) |

Higher‑level **`Ex_*`** entry points: **`docs/EXPORTED_EX_GLMBAYES.md`**.

---

## **`R CMD check`** import note

**Brief.** A documented reference to **`RcppParallel`** that exists solely so static analysis recognises **`DESCRIPTION`** **`Imports`** usage.

**Why nmathopencl (vs `openclport`).** Not **`openclport`**-related—it satisfies **`devtools`/`RCMD`** bookkeeping for **`Imports: RcppParallel`**.

**Details.** **`use_RcppParallel`** is tagged **`@noRd`**/`@keywords internal` and intentionally never invoked at runtime; **`NAMESPACE`** still reflects **`imports(RcppParallel)`**, while **`DESCRIPTION`** **`LinkingTo`** and **`configure`/`Makevars`** pull **`RcppParallel::RcppParallelLibs()`**. Removing the symbol without retaining other qualifying **`RcppParallel`** references can revive **`NOTE: unused Imports`**.

**File:** `R/internal_rcppparallel.R`

| Helper | Role |
|--------|------|
| `use_RcppParallel` | **`@noRd`** — satisfies **`Imports: RcppParallel`**; never called at runtime |

---

## Globals (non‑function)

**Brief.** Silence standard package checks about **`no visible binding for global`** when **`gpu_names()`** scaffolding references symbol names purely as strings.

**Why nmathopencl (vs `openclport`).** Check hygiene unrelated to **`openclport`** port metadata.

**Details.** **`utils::globalVariables`** pre-registers quoted names **`R CMD`** would otherwise flag; aside from this declaration **`globals.R`** contains no runnable helpers.

**File:** `R/globals.R`

| Declaration | Role |
|-------------|------|
| `utils::globalVariables(...)` | Silences **`R CMD check`** for NSE / quoted **`gpu_names`** strings |

---

## One‑line inventory (sorted by **`R/`** file)

| `R/` file | Internal helpers |
|-----------|-------------------|
| `attach_kernel_dependency_tags.R` | `build_function_definition_index`, `build_hidden_definition_name_set`, `collect_c_statements_from_lines`, `definition_name_candidates`, `extract_define_alias_map`, `extract_non_hidden_function_declarations`, `format_tag_csv_values`, `header_declared_non_hidden_functions`, `resolve_definition_file` |
| `cl_library_internals.R` | `.cl_concat_result`, `.cl_console_text_width`, `.cl_filter_stems`, `.cl_format_unknown_stems_warning`, `.cl_is_header_style_lib_stem`, `.cl_load_index`, `.cl_parse_opencl_kernel_names`, `.cl_parse_provides_symbols`, `.cl_print_truncated_symbols`, `.cl_wrap_comma_separated` |
| `ex_glmbayes.R` | `dpois2` |
| `internal_rcppparallel.R` | `use_RcppParallel` |
| `kernel_known_failures.R` | `.cl_format_opencl_known_failure_warning`, `.cl_known_failure_annotate_hit`, `.cl_known_failure_entries_ll`, `.cl_known_failure_launcher_basenames`, `.cl_known_failure_launcher_hit`, `.cl_known_failure_loaded_hit`, `.cl_maybe_warn_opencl_known_failures`, `.cl_read_opencl_known_failures_bundle`, `.cl_stem_normalize_set` |
| `kernel_lib_subset_methods.R` | `.cl_attach_extract_attrs`, `.cl_print_stems_numbered` |
| `opencl_linkage_utils.R` | `.encode_opencl_parallel`, `.opencl_try_or_fallback`, `.p_stage1_recycle_len`, `.validate_d_stage1_log`, `.validate_flag`, `.validate_n_scalar`, `.validate_p_stage1_tails`, `.validate_scalar_num` |
| `openclport_helpers.R` | `annotation_insert_after_shim_core_metadata`, `c_identifier_pattern`, `escape_regex`, `function_definition_names_from_text`, `function_definition_records_from_text`, `shim_classification_tag_pattern`, `strip_c_comments`, `strip_c_strings` |
| `stage_kernel_dependency_sort.R` | `%||%`, `annotation_insert_position`, `copy_sorted_kernel_files`, `copy_unresolved_kernel_files`, `cycle_min_rotation_key`, `cycle_path_canonical_key`, `cycle_report_from_unresolved`, `dependency_neighborhood`, `dependency_sort_prefix`, `parse_port_annotation`, `parse_port_scalar_annotation`, `read_kernel_sort_records`, `set_port_annotation`, `shim_inference_tag_insert_anchor`, `sort_by_order`, `sorted_records_to_data_frame`, `transitive_depends_for_file`, `unresolved_records_to_data_frame` |
| `write_kernel_dependency_index.R` | `kernel_dependency_index_list_from_tags`, `split_kernel_depends_csv_char` |

---

## Regenerate checklist

After adding top‑level unexported **`R`** functions outside the excluded **`Rcpp`** glue files:

1. Run **`Rscript scripts/list_unexported_helpers.R .`** from the package root.
2. Update the thematic sections and the consolidated table above so wording matches behaviour.
