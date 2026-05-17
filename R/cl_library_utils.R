#' Load or extract a subset of annotated OpenCL `.cl` library files
#'
#' Delegates to [openclport::load_library_for_kernel()] and
#' [openclport::extract_library_subset()]. Kernels annotated with e.g.
#' `\verb{@all_depends_nmath}` pair with indexes under \verb{nmathopencl}.
#'
#' @name nmathocl_kernel_library_subset
NULL

#' @rdname nmathocl_kernel_library_subset
#' @export
load_library_for_kernel <- openclport::load_library_for_kernel

#' @rdname nmathocl_kernel_library_subset
#' @export
extract_library_subset <- openclport::extract_library_subset
