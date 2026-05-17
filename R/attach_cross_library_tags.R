#' Attach cross-library dependency tags (`@depends_*` kernels)
#'
#' Wrapper around [openclport::attach_cross_library_tags()]. Typical kernels
#' use `\verb{@depends_nmath}` and the compiled index shipped under
#' [system.file("cl/nmath", package = "nmathopencl")].
#'
#' @export
attach_cross_library_tags <- openclport::attach_cross_library_tags
