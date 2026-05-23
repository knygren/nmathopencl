# `src/nmath`

Vendor **Mathlib (`nmath`)** C/H sources mirrored for **native** (**CPU**) parity with **`stats`** / **`Rmath`**.

## Where OpenCL tailoring belongs (not here)

Maintain **upstream-style** **`ML_WARNING`** / **`ML_WARN_return_NAN`** in this tree (same **`char *msg`** + string-literal shape as **`nmath`**). Do **not** add OpenCL-only “no-op warning” tweaks under **`nmathopencl/src/nmath`**.

Portable OpenCL shaders are staged from **`Port_nmath_to_opencl.R`**, which reads **only**:

**`<openclport_workflow_root>/nmath_refactored/`**

(see **`openclport/nmathtools/Port_nmath_to_opencl.R`**, STEP 0 **`source_dir`**). **`ML_*`** adjustments for **`clBuildProgram`** live in **`nmath_refactored/nmath.h`**, alongside the refactored **`.c`**. The flat **original** tree **`…/openclport/nmath/`** stays unmodified Mathlib—do not replicate OpenCL hacks there either.

Rough layout on the maintainer machine:

| Directory | Role |
|-----------|------|
| **`…/openclport/nmath/`** | Original flattened Mathlib — **never** OpenCL-tailor **`nmath.h`** here |
| **`…/openclport/nmath_refactored/`** | Input to **`Port_nmath_to_opencl`** STEP **1**; **`nmath.h`** may carry OpenCL-safe **`ML_*`** here only |
| **`nmathopencl/src/nmath/`** | Package vendor mirror (**host** **`ML_*`**) aligned with **`openclport/nmath`**, **not** the refactor hacks |

Then copy staged **`*.cl`** from **`out_base/nmath`** (or equivalent) into **`nmathopencl/inst/cl/nmath`** as your workflow dictates.

### Optional script: **`port_inst_cl_nmath_from_src.R`**

**`openclport/nmathtools/port_inst_cl_nmath_from_src.R`** emits **`nm_repo/inst/cl/nmath`** from **`nm_repo/src/nmath`** only. Because **`src/nmath`** intentionally keeps **host** **`ML_*`**, running it alone produces device sources that lack the refactor OpenCL tweaks—use **`Port_nmath_to_opencl`** (**`nmath_refactored`**) for GPU-correct kernels, unless **`src/nmath`** has been explicitly synced **from refactored** (policy choice).
