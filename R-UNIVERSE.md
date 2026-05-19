# nmathopencl on R-universe

This note is for **maintainers**: how **`nmathopencl`** surfaces on
**[r-universe](https://docs.r-universe.dev/)** (manual, vignettes, binaries)
and how that relates to **`packages.json`**.

**Canonical registry (`knygren` universe):** Keep **`packages.json`** on **`knygren/knygren.r-universe.dev` `main`** in the **[documented](https://docs.r-universe.dev/publish/set-up.html)** JSON **array** form (`package` + `url`). Packages on **CRAN** with your GitHub in DESCRIPTION can additionally be **[auto-listed](https://docs.r-universe.dev/publish/set-up.html#sec-special-case-of-cran-packages)**.

**Operational trigger (`glmbayes`, `nmathopencl`):** Maintainer practice under **`github.com/knygren`**: pushing an updated **`packages.json` at that package's repo root** (same shorthand **`"pkg":"user/repo"`** map mirrored in **`glmbayes`** and **`nmathopencl`**) has reliably **kick-started / refreshed** builds on **`knygren.r-universe.dev`**, including cases where **`r-universe[bot]`** bumps **`github.com/r-universe/knygren/.ghapp`** **`repositories`** once **`nmathopencl`** is part of your universe lineup. **`R CMD build`** can ignore that file (**`.Rbuildignore`** here); pushes still ship it to GitHub for clones and automation hooks.

Treat the **two** artefacts together: authoritative listing on **`knygren.r-universe.dev`** plus an occasional **repo-root** `packages.json` push whenever you intentionally **signal** fresh universe work---as you've done historically for **`glmbayes`**.

## Canonical R-universe registry (what builders actually read)

Builders watch a dedicated GitHub repository whose name equals your universe
hostname, usually:

| Universe URL | Repository that must hold `packages.json` |
|----------------|-------------------------------------------|
| `https://knygren.r-universe.dev` | **`knygren/knygren.r-universe.dev`** (all lowercase subdomain) |

The registry file **`packages.json` in that repo** must follow the [**documented schema**](https://docs.r-universe.dev/publish/set-up/) (recommended: JSON **array** of objects with **`package`** and **`url`**), for example:

```json
[
  {
    "package": "glmbayes",
    "url": "https://github.com/knygren/glmbayes"
  },
  {
    "package": "nmathopencl",
    "url": "https://github.com/knygren/nmathopencl"
  }
]
```

The **canonical** **`packages.json`** still lives under **`knygren/knygren.r-universe.dev`**
(documented schema). **Empirically** for **`knygren`**, syncing **repository-root **`packages.json`**
inside **`glmbayes`** / **`nmathopencl`** with GitHub has **paired** that registry---not replaced it---for **kick-starting rebuilds**.

If the control-panel / subdomain-repo workflow fails, usual causes are naming
(repo must match **`hostname.r-universe.dev`**), JSON shape, Actions disabled,
or permissions---see troubleshooting in the [**set-up guide**](https://docs.r-universe.dev/publish/set-up/).

## Local `packages.json` copy (repository roots)

Keeping a **`packages.json`** next to **`DESCRIPTION`** in [`glmbayes`](https://github.com/knygren/glmbayes)
and [`nmathopencl`](https://github.com/knygren/nmathopencl)
is a maintainer shorthand (same **`"pkg": "user/repo"`** map in either repo).
**`R CMD build` ignores this file via `.Rbuildignore`** (`nmathopencl`) so CRAN tarballs
omit it; **R-universe still clones the full git repo** when building.

The officially processed registry stays **`packages.json`** in **`knygren/knygren.r-universe.dev`**
converted to **`package` + full `url`** objects (documented schema above)---copy from these
locals when syncing.

## What builders produce once listed

Typical artifacts for each indexed package:

| Artifact | Meaning |
|----------|---------|
| Binaries / sources | Built when linking succeeds |
| HTML **manual** | All `.Rd`, linked |
| **Articles** | Vignettes |

Badge (example): **`https://knygren.r-universe.dev/badges/nmathopencl`**.

## OpenCL / `configure` note

The package installs and runs **without** OpenCL. Universe/Linux snapshots often
produce **CPU-only binaries** unless the worker has SDK + libraries; vignette
*Chapter 01* documents local GPU installs.

For **rapid GPU iteration**, build from source beside a vendor SDK
(`R CMD INSTALL`).

## Troubleshooting --- "nothing happened when I pushed"

Understanding **what** R-universe watches avoids confusion:

| What you push | Typical effect |
|---------------|----------------|
| **`knygren/knygren.r-universe.dev`** only (valid `packages.json`) | Registers or updates **which repos** Universe builds from. Requires the **[R-universe GitHub app](https://github.com/apps/r-universe/installations/new)** installed on your GitHub user/org (recommended: all repositories). |
| **`knygren/glmbayes`** or **`knygren/nmathopencl`** (repo-root **`packages.json`**) | **Operational trigger** for **`knygren`** maintainers once that repo sits in **`r-universe/knygren/.ghapp` `repositories`**: pushes have **often** restarted matrix builds---not a substitute for the registry file **`knygren.r-universe.dev`**. Cadence varies; **[docs timing](https://docs.r-universe.dev/publish/set-up.html)** still apply for edge cases (**metadata-only** rows, periodic rescans ~**30 days** mention). |

**JSON shape:** If `packages.json` in **`knygren.r-universe.dev`** used the shorthand `{"glmbayes":"knygren/glmbayes"}` instead of the required **`[{"package":"...","url":"https://..."}, ...]`** array, the formal registry may be ignored -> fix the schema and push again ([example](https://github.com/maelle/maelle.r-universe.dev/blob/main/packages.json)).

**Where builds appear:** Completed work surfaces on **`https://knygren.r-universe.dev`**, while **Actions** usually run under the mirrored monorepo **`https://github.com/r-universe/knygren`** (not necessarily on each package repo's Actions tab)---see [**set-up -> waiting for first build**](https://docs.r-universe.dev/publish/set-up.html).

If it still stalls after a valid registry + installed app + wait interval, ask in [**r-universe-org/help** discussions](https://github.com/r-universe-org/help/discussions) with links to your registry repo and a package URL.
