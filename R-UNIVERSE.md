# nmathopencl on R-universe

This note is for **maintainers**: how **`nmathopencl`** surfaces on
**[r-universe](https://docs.r-universe.dev/)** (manual, vignettes, binaries)
and how that relates to **`packages.json`**.

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
exists inside **`glmbayes`** unless you replicate or generate that listing into
the **`{user}.r-universe.dev`** repository (or equivalent automation).

If the control-panel / subdomain-repo workflow fails, usual causes are naming
(repo must match **`hostname.r-universe.dev`**), JSON shape, Actions disabled,
or permissions—see troubleshooting in the [**set-up guide**](https://docs.r-universe.dev/publish/set-up/).

## Local `packages.json` in the `glmbayes` repository

Keeping a **`packages.json` in [`glmbayes`](https://github.com/knygren/glmbayes)
repo root** is a **maintainer-side mirror**: one place listing every package URL
you care about (`glmbayes`, **`nmathopencl`**, future siblings). Edit that copy
when you add packages, then reflect the same entries into
**`knygren/knygren.r-universe.dev`** when syncing (or automate copy if you wire
your own CI).

The shorthand `"pkg": "user/repo"` form is handy for humans; universe’s checker
typically expects **`package`** + **`url`** as in the snippet above—convert when
writing the official registry file.

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

