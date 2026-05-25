# Re-exports from opencltools (Tier 4: kernel library authoring / subset loading).
# Tier 3 runtime/system diagnostics live in opencltools only; call opencltools::.

#' @export
#' @inherit opencltools::attach_kernel_call_tags
attach_kernel_call_tags <- opencltools::attach_kernel_call_tags

#' @export
#' @inherit opencltools::attach_kernel_dependency_tags
attach_kernel_dependency_tags <- opencltools::attach_kernel_dependency_tags

#' @export
#' @inherit opencltools::attach_cross_library_tags
attach_cross_library_tags <- opencltools::attach_cross_library_tags

#' @export
#' @inherit opencltools::write_kernel_dependency_index
write_kernel_dependency_index <- opencltools::write_kernel_dependency_index

#' @export
#' @inherit opencltools::stage_kernel_dependency_sort
stage_kernel_dependency_sort <- opencltools::stage_kernel_dependency_sort

#' @export
#' @inherit opencltools::extract_library_subset
extract_library_subset <- opencltools::extract_library_subset

#' @export
#' @inherit opencltools::load_library_for_kernel
load_library_for_kernel <- opencltools::load_library_for_kernel
