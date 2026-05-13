# -------------------------------------------------------------------------
#  Rcpp Interface Wrappers – glmbayes EnvelopeEval Example
#
#  These wrappers exist solely to support the Ex_EnvelopeEval example
#  (ex_glmbayes.R).  They are NOT part of the core nmathopencl API.
#  If the example is removed in the future, this file can be deleted along
#  with ex_glmbayes.R.
# -------------------------------------------------------------------------

# =============================================================================
#  Tier 2: Envelope & Standardization
#  Callers: Ex_EnvelopeSize, Ex_EnvelopeEval
#  User:    Downstream packages building custom OpenCL kernels on nmath
# =============================================================================

#' @noRd
#' @keywords internal
.EnvelopeSize_cpp <- function(a, G1, Gridtype, n, n_envopt, use_opencl, verbose) {
  .Call(`_nmathopencl_EnvelopeSize_cpp_export`, a, G1, Gridtype, n, n_envopt, use_opencl, verbose)
}

#' @noRd
#' @keywords internal
.EnvelopeEval_cpp <- function(G4, y, x, mu, P, alpha, wt,
                          family, link,
                          use_opencl = FALSE,
                          verbose = FALSE) {
  .Call(`_nmathopencl_EnvelopeEval_cpp_export`,
        G4, y, x, mu, P, alpha, wt,
        family, link,
        use_opencl, verbose)
}

# =============================================================================
#  Tier 3: Model Utilities
#  Callers: Ex_glmb_Standardize_Model
#  User:    Advanced users – model preparation, standardization
# =============================================================================

#' @noRd
#' @keywords internal
.glmb_Standardize_Model_cpp <- function(y, x, P, bstar, A1) {
  .Call(`_nmathopencl_glmb_Standardize_Model_cpp_export`, y, x, P, bstar, A1)
}
