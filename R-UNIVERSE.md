# nmathopencl on R-universe

This note is for **maintainers**: how **`nmathopencl`** surfaces on
**[r-universe](https://docs.r-universe.dev/)** (manual, vignettes, binaries)
and how that relates to **`packages.json`**.

**No substitute:** A **`packages.json` in `nmathopencl`/`glmbayes` does *not*
replace **`knygren/knygren.r-universe.dev`**. Those root files are for your convenience
only. R‑universe discovers **which repos to clone** solely from (**a**) **`packages.json`**
committed to **`knygren/knygren.r-universe.dev`**, (**b**) a **fallback scan of CRAN** for packages whose
DESCRIPTION lists your GitHub—see [docs §11.3.1](https://docs.r-universe.dev/publish/set-up.html)—or **(c)** a mix when you add **`packages.json`**
later (manual registry then takes precedence).

**Practical implication:** **`glmbayes`** often appears on `knygren.r-universe.dev`
automatically because it is on CRAN and its DESCRIPTION links your GitHub repo.
**`nmathopencl`** is not on CRAN, so it is **not** included by that scraper and
generally **needs** a conforming **`packages.json`** in **`knygren/knygren.r-universe.dev`**
to be built (until you publish elsewhere with a discoverable Git URL, if applicable).

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

Universe sync does **not** automatically ingest a `packages.json` that only
lives inside a **package repo** (**`glmbayes`** / **`nmathopencl`**)—you still need
those entries mirrored into **`knygren/knygren.r-universe.dev`** using the documented
schema.

If the control-panel / subdomain-repo workflow fails, usual causes are naming
(repo must match **`hostname.r-universe.dev`**), JSON shape, Actions disabled,
or permissions—see troubleshooting in the [**set-up guide**](https://docs.r-universe.dev/publish/set-up/).

## Local `packages.json` copy (repository roots)

Keeping a **`packages.json`** next to **`DESCRIPTION`** in [`glmbayes`](https://github.com/knygren/glmbayes)
and [`nmathopencl`](https://github.com/knygren/nmathopencl)
is a maintainer shorthand (same **`"pkg": "user/repo"`** map in either repo).
**`R CMD build` ignores this file via `.Rbuildignore`** (`nmathopencl`) so CRAN tarballs
omit it; **R-universe still clones the full git repo** when building.

The officially processed registry stays **`packages.json`** in **`knygren/knygren.r-universe.dev`**
converted to **`package` + full `url`** objects (documented schema above)—copy from these
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
*Chapter 01* documents local GPU installs.

For **rapid GPU iteration**, build from source beside a vendor SDK
(`R CMD INSTALL`).

## Troubleshooting — “nothing happened when I pushed”

Understanding **what** R-universe watches avoids confusion:

| What you push | Typical effect |
|---------------|----------------|
| **`knygren/knygren.r-universe.dev`** only (valid `packages.json`) | Registers or updates **which repos** Universe builds from. Requires the **[R-universe GitHub app](https://github.com/apps/r-universe/installations/new)** installed on your GitHub user/org (recommended: all repositories). |
| **`knygren/glmbayes`** or **`knygren/nmathopencl`** | Does **not** change the registry file. Once a repo is listed in `packages.json`, the build system pulls from that Git URL **on its own cadence**, not instantly on every git push. The first dashboard appearance can take **up to roughly an hour**; later updates appear after periodic sync rebuilds (**metadata-only** tweaks may wait until **30 days** or need a triggering commit per [docs](https://docs.r-universe.dev/publish/set-up.html)). |

**JSON shape:** If `packages.json` in **`knygren.r-universe.dev`** used the shorthand `{"glmbayes":"knygren/glmbayes"}` instead of the required **`[{"package":"...","url":"https://..."}, ...]`** array, the formal registry may be ignored → fix the schema and push again ([example](https://github.com/maelle/maelle.r-universe.dev/blob/main/packages.json)).

**Where builds appear:** Completed work surfaces on **`https://knygren.r-universe.dev`**, while **Actions** usually run under the mirrored monorepo **`https://github.com/r-universe/knygren`** (not necessarily on each package repo’s Actions tab)—see [**set-up → waiting for first build**](https://docs.r-universe.dev/publish/set-up.html).

If it still stalls after a valid registry + installed app + wait interval, ask in [**r-universe-org/help** discussions](https://github.com/r-universe-org/help/discussions) with links to your registry repo and a package URL.

