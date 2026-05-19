# -------------------------------------------------------------------------
#  Rcpp Interface Wrappers for glmbayes
#
#  These functions provide the minimal, strictly positional R -> C++ bridges
#  required by the package.  Each wrapper mirrors the exact argument order
#  expected by the corresponding C++ routine and performs no preprocessing,
#  validation, or postprocessing.  Their sole purpose is to ensure that
#  high-level R code calls the correct compiled symbol with the correct
#  signature.
#
#  All wrappers are internal:
#    - They are not part of the public API.
#    - They exist only to guarantee stable, explicit R-C++ boundaries.
#    - They prevent accidental reliance on .Call() with named arguments,
#      which R ignores, and which can silently break when signatures change.
#
#  Any future C++ interface changes must be reflected here to maintain
#  positional consistency and avoid NULL -> double coercion errors.
#
#  Wrappers are organized by tier:
#    Tier 2: Envelope          - EnvelopeSize, EnvelopeEval, glmb_Standardize_Model
#    Tier 3: Model Utilities   - Standardization helpers
#    Tier 4: OpenCL/GPU        - Kernel loading, GPU diagnostics
# -------------------------------------------------------------------------
# =============================================================================
#  Tier 2: Envelope & Standardization
#  Callers: Ex_EnvelopeSize, Ex_EnvelopeEval, Ex_glmb_Standardize_Model
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
#  User:    Advanced users - model preparation, standardization
# =============================================================================

#' @noRd
#' @keywords internal
.glmb_Standardize_Model_cpp <- function(y, x, P, bstar, A1) {
  .Call(`_nmathopencl_glmb_Standardize_Model_cpp_export`, y, x, P, bstar, A1)
}


# =============================================================================
#  Tier 4: OpenCL / GPU
#  Callers: load_kernel_source, load_kernel_library, has_opencl,
#           get_opencl_core_count, gpu_names
#  User:    Advanced users - GPU diagnostics, kernel loading for use_opencl
# =============================================================================

#' @noRd
#' @keywords internal
.load_kernel_source_wrapper_cpp <- function(relative_path, package = "nmathopencl") {
  .Call(`_nmathopencl_load_kernel_source_wrapper_cpp_export`, relative_path, package)
}

#' @noRd
#' @keywords internal
.load_kernel_library_wrapper_cpp <- function(subdir, package = "nmathopencl", verbose = FALSE) {
  .Call(`_nmathopencl_load_kernel_library_wrapper_cpp_export`, subdir, package, verbose)
}

#' @noRd
#' @keywords internal
.has_opencl_cpp <- function() {
  .Call("_nmathopencl_has_opencl_cpp_export")
}

#' @noRd
#' @keywords internal
.get_opencl_core_count_cpp <- function() {
  .Call("_nmathopencl_get_opencl_core_count_cpp_export")
}

#' @noRd
#' @keywords internal
.gpu_names_cpp <- function() {
  .Call("_nmathopencl_gpu_names_cpp_export")
}

#' @noRd
#' @keywords internal
.dnorm_opencl <- function(x, mean, sd, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dnorm_opencl_cpp_export`,
    x,
    mean,
    sd,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.runif_opencl <- function(n, min = 0, max = 1, verbose = FALSE) {
  .Call(`_nmathopencl_runif_opencl_cpp_export`, n, min, max, verbose)
}

#' @noRd
#' @keywords internal
.rnorm_opencl <- function(n, mean = 0, sd = 1, verbose = FALSE) {
  .Call(`_nmathopencl_rnorm_opencl_cpp_export`, n, mean, sd, verbose)
}

#' @noRd
#' @keywords internal
.rexp_opencl <- function(n, rate = 1, verbose = FALSE) {
  .Call(`_nmathopencl_rexp_opencl_cpp_export`, n, 1 / rate, verbose)
}

#' @noRd
#' @keywords internal
.rwilcox_opencl <- function(n, m, nn, verbose = FALSE) {
  .Call(`_nmathopencl_rwilcox_opencl_cpp_export`, n, m, nn, verbose)
}

#' @noRd
#' @keywords internal
.rbinom_opencl <- function(n, size, prob, verbose = FALSE) {
  .Call(`_nmathopencl_rbinom_opencl_cpp_export`, n, size, prob, verbose)
}

#' @noRd
#' @keywords internal
.r_pow_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_r_pow_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.r_pow_di_opencl <- function(x, n_exp, verbose = FALSE) {
  .Call(`_nmathopencl_r_pow_di_opencl_cpp_export`, x, n_exp, verbose)
}

#' @noRd
#' @keywords internal
.log1pmx_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_log1pmx_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.log1pexp_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_log1pexp_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.log1mexp_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_log1mexp_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.lgamma1p_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_lgamma1p_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.pow1p_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_pow1p_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.logspace_add_opencl <- function(logx, logy, verbose = FALSE) {
  .Call(`_nmathopencl_logspace_add_opencl_cpp_export`, logx, logy, verbose)
}

#' @noRd
#' @keywords internal
.logspace_sub_opencl <- function(logx, logy, verbose = FALSE) {
  .Call(`_nmathopencl_logspace_sub_opencl_cpp_export`, logx, logy, verbose)
}

#' @noRd
#' @keywords internal
.logspace_sum_opencl <- function(logx, logy, verbose = FALSE) {
  .Call(`_nmathopencl_logspace_sum_opencl_cpp_export`, logx, logy, verbose)
}

#' @noRd
#' @keywords internal
.norm_rand_opencl <- function(n, verbose = FALSE) {
  .Call(`_nmathopencl_norm_rand_opencl_cpp_export`, n, verbose)
}

#' @noRd
#' @keywords internal
.unif_rand_opencl <- function(n, verbose = FALSE) {
  .Call(`_nmathopencl_unif_rand_opencl_cpp_export`, n, verbose)
}

#' @noRd
#' @keywords internal
.r_unif_index_opencl <- function(n, dn, verbose = FALSE) {
  .Call(`_nmathopencl_r_unif_index_opencl_cpp_export`, n, dn, verbose)
}

#' @noRd
#' @keywords internal
.exp_rand_opencl <- function(n, verbose = FALSE) {
  .Call(`_nmathopencl_exp_rand_opencl_cpp_export`, n, verbose)
}

#' @noRd
#' @keywords internal
.pnorm_opencl <- function(q, mean, sd, lower_tail, log_p, opencl_parallel, verbose = FALSE) {
  .Call(
    `_nmathopencl_pnorm_opencl_cpp_export`,
    q,
    mean,
    sd,
    as.integer(lower_tail),
    as.integer(log_p),
    as.integer(opencl_parallel)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.qnorm_opencl <- function(p, mean, sd, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qnorm_opencl_cpp_export`,
    p,
    mean,
    sd,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dunif_opencl <- function(x, min, max, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dunif_opencl_cpp_export`,
    x,
    min,
    max,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.punif_opencl <- function(q, min, max, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_punif_opencl_cpp_export`,
    q,
    min,
    max,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qunif_opencl <- function(p, min, max, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qunif_opencl_cpp_export`,
    p,
    min,
    max,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dgamma_opencl <- function(x, shape, scale, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dgamma_opencl_cpp_export`,
    x,
    shape,
    scale,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pgamma_opencl <- function(q, shape, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pgamma_opencl_cpp_export`,
    q,
    shape,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qgamma_opencl <- function(p, shape, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qgamma_opencl_cpp_export`,
    p,
    shape,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rgamma_opencl <- function(n, shape, scale, verbose = FALSE) {
  .Call(`_nmathopencl_rgamma_opencl_cpp_export`, n, shape, scale, verbose)
}

#' @noRd
#' @keywords internal
.dbeta_opencl <- function(x, shape1, shape2, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dbeta_opencl_cpp_export`,
    x,
    shape1,
    shape2,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pbeta_opencl <- function(q, shape1, shape2, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pbeta_opencl_cpp_export`,
    q,
    shape1,
    shape2,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qbeta_opencl <- function(p, shape1, shape2, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qbeta_opencl_cpp_export`,
    p,
    shape1,
    shape2,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rbeta_opencl <- function(n, a, b, verbose = FALSE) {
  .Call(`_nmathopencl_rbeta_opencl_cpp_export`, n, a, b, verbose)
}

#' @noRd
#' @keywords internal
.dlnorm_opencl <- function(x, meanlog, sdlog, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dlnorm_opencl_cpp_export`,
    x,
    meanlog,
    sdlog,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.plnorm_opencl <- function(q, meanlog, sdlog, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_plnorm_opencl_cpp_export`,
    q,
    meanlog,
    sdlog,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qlnorm_opencl <- function(p, meanlog, sdlog, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qlnorm_opencl_cpp_export`,
    p,
    meanlog,
    sdlog,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rlnorm_opencl <- function(n, meanlog, sdlog, verbose = FALSE) {
  .Call(`_nmathopencl_rlnorm_opencl_cpp_export`, n, meanlog, sdlog, verbose)
}

#' @noRd
#' @keywords internal
.dchisq_opencl <- function(x, df, ncp, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dchisq_opencl_cpp_export`,
    x,
    df,
    ncp,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pchisq_opencl <- function(q, df, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pchisq_opencl_cpp_export`,
    q,
    df,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qchisq_opencl <- function(p, df, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qchisq_opencl_cpp_export`,
    p,
    df,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rchisq_opencl <- function(n, df, verbose = FALSE) {
  .Call(`_nmathopencl_rchisq_opencl_cpp_export`, n, df, verbose)
}

#' @noRd
#' @keywords internal
.rnchisq_opencl <- function(n, df, ncp, verbose = FALSE) {
  .Call(`_nmathopencl_rnchisq_opencl_cpp_export`, n, df, ncp, verbose)
}

#' @noRd
#' @keywords internal
.df_opencl <- function(x, df1, df2, ncp, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_df_opencl_cpp_export`,
    x,
    df1,
    df2,
    ncp,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pf_opencl <- function(q, df1, df2, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pf_opencl_cpp_export`,
    q,
    df1,
    df2,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qf_opencl <- function(p, df1, df2, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qf_opencl_cpp_export`,
    p,
    df1,
    df2,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rf_opencl <- function(n, df1, df2, verbose = FALSE) {
  .Call(`_nmathopencl_rf_opencl_cpp_export`, n, df1, df2, verbose)
}

#' @noRd
#' @keywords internal
.dt_opencl <- function(x, df, ncp, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dt_opencl_cpp_export`,
    x,
    df,
    ncp,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pt_opencl <- function(q, df, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pt_opencl_cpp_export`,
    q,
    df,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qt_opencl <- function(p, df, ncp, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qt_opencl_cpp_export`,
    p,
    df,
    ncp,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rt_opencl <- function(n, df, verbose = FALSE) {
  .Call(`_nmathopencl_rt_opencl_cpp_export`, n, df, verbose)
}

#' @noRd
#' @keywords internal
.dbinom_raw_opencl <- function(x, n_size, prob, qprob, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dbinom_raw_opencl_cpp_export`,
    x,
    n_size,
    prob,
    qprob,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.dbinom_opencl <- function(x, size, prob, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dbinom_opencl_cpp_export`,
    x,
    size,
    prob,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pbinom_opencl <- function(q, size, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pbinom_opencl_cpp_export`,
    q,
    size,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dnbinom_opencl <- function(x, size, prob, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dnbinom_opencl_cpp_export`,
    x,
    size,
    prob,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pnbinom_opencl <- function(q, size, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pnbinom_opencl_cpp_export`,
    q,
    size,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qnbinom_opencl <- function(p, size, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qnbinom_opencl_cpp_export`,
    p,
    size,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rnbinom_opencl <- function(n, size, prob, verbose = FALSE) {
  .Call(`_nmathopencl_rnbinom_opencl_cpp_export`, n, size, prob, verbose)
}

#' @noRd
#' @keywords internal
.dnbinom_mu_opencl <- function(x, size, mu, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dnbinom_mu_opencl_cpp_export`,
    x,
    size,
    mu,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pnbinom_mu_opencl <- function(q, size, mu, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pnbinom_mu_opencl_cpp_export`,
    q,
    size,
    mu,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rmultinom_opencl <- function(n, size, prob, verbose = FALSE) {
  .Call(`_nmathopencl_rmultinom_opencl_cpp_export`, n, size, prob, verbose)
}

#' @noRd
#' @keywords internal
.dcauchy_opencl <- function(x, location, scale, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dcauchy_opencl_cpp_export`,
    x,
    location,
    scale,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pcauchy_opencl <- function(q, location, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pcauchy_opencl_cpp_export`,
    q,
    location,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qcauchy_opencl <- function(p, location, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qcauchy_opencl_cpp_export`,
    p,
    location,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rcauchy_opencl <- function(n, location, scale, verbose = FALSE) {
  .Call(`_nmathopencl_rcauchy_opencl_cpp_export`, n, location, scale, verbose)
}

#' @noRd
#' @keywords internal
.dexp_opencl <- function(x, rate, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dexp_opencl_cpp_export`,
    x,
    rate,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pexp_opencl <- function(q, rate, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pexp_opencl_cpp_export`,
    q,
    rate,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qexp_opencl <- function(p, rate, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qexp_opencl_cpp_export`,
    p,
    rate,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dgeom_opencl <- function(x, prob, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dgeom_opencl_cpp_export`,
    x,
    prob,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pgeom_opencl <- function(q, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pgeom_opencl_cpp_export`,
    q,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qgeom_opencl <- function(p, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qgeom_opencl_cpp_export`,
    p,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rgeom_opencl <- function(n, prob, verbose = FALSE) {
  .Call(`_nmathopencl_rgeom_opencl_cpp_export`, n, prob, verbose)
}

#' @noRd
#' @keywords internal
.dhyper_opencl <- function(x, r, b, n1, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dhyper_opencl_cpp_export`,
    x,
    r,
    b,
    n1,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.phyper_opencl <- function(q, m, n_black, k, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_phyper_opencl_cpp_export`,
    q,
    m,
    n_black,
    k,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qhyper_opencl <- function(p, r, b, n1, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qhyper_opencl_cpp_export`,
    p,
    r,
    b,
    n1,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rhyper_opencl <- function(n, r, b, n1, verbose = FALSE) {
  .Call(`_nmathopencl_rhyper_opencl_cpp_export`, n, r, b, n1, verbose)
}

#' @noRd
#' @keywords internal
.qbinom_opencl <- function(p, size, prob, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qbinom_opencl_cpp_export`,
    p,
    size,
    prob,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qpois_opencl <- function(p, lambda, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qpois_opencl_cpp_export`,
    p,
    lambda,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dpois_raw_opencl <- function(x, lambda, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dpois_raw_opencl_cpp_export`,
    x,
    lambda,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.dpois_opencl <- function(x, lambda, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dpois_opencl_cpp_export`,
    x,
    lambda,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.ppois_opencl <- function(q, lambda, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_ppois_opencl_cpp_export`,
    q,
    lambda,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qnbinom_mu_opencl <- function(p, size, mu, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qnbinom_mu_opencl_cpp_export`,
    p,
    size,
    mu,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rpois_opencl <- function(n, lambda, verbose = FALSE) {
  .Call(`_nmathopencl_rpois_opencl_cpp_export`, n, lambda, verbose)
}

#' @noRd
#' @keywords internal
.rnbinom_mu_opencl <- function(n, size, mu, verbose = FALSE) {
  .Call(`_nmathopencl_rnbinom_mu_opencl_cpp_export`, n, size, mu, verbose)
}

#' @noRd
#' @keywords internal
.dweibull_opencl <- function(x, shape, scale, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dweibull_opencl_cpp_export`,
    x,
    shape,
    scale,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pweibull_opencl <- function(q, shape, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pweibull_opencl_cpp_export`,
    q,
    shape,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qweibull_opencl <- function(p, shape, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qweibull_opencl_cpp_export`,
    p,
    shape,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rweibull_opencl <- function(n, shape, scale, verbose = FALSE) {
  .Call(`_nmathopencl_rweibull_opencl_cpp_export`, n, shape, scale, verbose)
}

#' @noRd
#' @keywords internal
.dlogis_opencl <- function(x, location, scale, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dlogis_opencl_cpp_export`,
    x,
    location,
    scale,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.plogis_opencl <- function(q, location, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_plogis_opencl_cpp_export`,
    q,
    location,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qlogis_opencl <- function(p, location, scale, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qlogis_opencl_cpp_export`,
    p,
    location,
    scale,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rlogis_opencl <- function(n, location, scale, verbose = FALSE) {
  .Call(`_nmathopencl_rlogis_opencl_cpp_export`, n, location, scale, verbose)
}

#' @noRd
#' @keywords internal
.dnbeta_opencl <- function(x, shape1, shape2, ncp, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dnbeta_opencl_cpp_export`,
    x,
    shape1,
    shape2,
    ncp,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.ptukey_opencl <- function(q, nmeans, df, nranges, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_ptukey_opencl_cpp_export`,
    q,
    nmeans,
    df,
    nranges,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qtukey_opencl <- function(
    p,
    nmeans,
    df,
    nranges,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose = FALSE
) {
  .Call(
    `_nmathopencl_qtukey_opencl_cpp_export`,
    p,
    nmeans,
    df,
    nranges,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dwilcox_opencl <- function(x, m, n2, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dwilcox_opencl_cpp_export`,
    x,
    m,
    n2,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.pwilcox_opencl <- function(q, m, n2, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_pwilcox_opencl_cpp_export`,
    q,
    m,
    n2,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qwilcox_opencl <- function(p, m, n2, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qwilcox_opencl_cpp_export`,
    p,
    m,
    n2,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.dsignrank_opencl <- function(x, nsize, log, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_dsignrank_opencl_cpp_export`,
    x,
    nsize,
    as.integer(log),
    as.integer(opencl_parallel_code)[1L],
    verbose
  )
}

#' @noRd
#' @keywords internal
.psignrank_opencl <- function(q, nsize, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_psignrank_opencl_cpp_export`,
    q,
    nsize,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.qsignrank_opencl <- function(p, nsize, lower_tail, log_p, opencl_parallel_code, verbose = FALSE) {
  .Call(
    `_nmathopencl_qsignrank_opencl_cpp_export`,
    p,
    nsize,
    lower_tail,
    log_p,
    opencl_parallel_code,
    verbose
  )
}

#' @noRd
#' @keywords internal
.rsignrank_opencl <- function(n, nsize, verbose = FALSE) {
  .Call(`_nmathopencl_rsignrank_opencl_cpp_export`, n, nsize, verbose)
}

#' @noRd
#' @keywords internal
.gammafn_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_gammafn_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.lgammafn_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_lgammafn_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.lgammafn_sign_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_lgammafn_sign_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.dpsifn_opencl <- function(x, n_deriv, kode, m, verbose = FALSE) {
  .Call(`_nmathopencl_dpsifn_opencl_cpp_export`, x, n_deriv, kode, m, verbose)
}

#' @noRd
#' @keywords internal
.psigamma_opencl <- function(x, deriv, verbose = FALSE) {
  .Call(`_nmathopencl_psigamma_opencl_cpp_export`, x, deriv, verbose)
}

#' @noRd
#' @keywords internal
.digamma_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_digamma_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.trigamma_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_trigamma_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.tetragamma_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_tetragamma_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.pentagamma_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_pentagamma_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.beta_opencl <- function(a, b, verbose = FALSE) {
  .Call(`_nmathopencl_beta_opencl_cpp_export`, a, b, verbose)
}

#' @noRd
#' @keywords internal
.lbeta_opencl <- function(a, b, verbose = FALSE) {
  .Call(`_nmathopencl_lbeta_opencl_cpp_export`, a, b, verbose)
}

#' @noRd
#' @keywords internal
.choose_opencl <- function(n_val, k, verbose = FALSE) {
  .Call(`_nmathopencl_choose_opencl_cpp_export`, n_val, k, verbose)
}

#' @noRd
#' @keywords internal
.lchoose_opencl <- function(n_val, k, verbose = FALSE) {
  .Call(`_nmathopencl_lchoose_opencl_cpp_export`, n_val, k, verbose)
}

#' @noRd
#' @keywords internal
.bessel_i_opencl <- function(x, nu, expo_scaled, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_i_opencl_cpp_export`, x, nu, expo_scaled, verbose)
}

#' @noRd
#' @keywords internal
.bessel_j_opencl <- function(x, nu, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_j_opencl_cpp_export`, x, nu, verbose)
}

#' @noRd
#' @keywords internal
.bessel_k_opencl <- function(x, nu, expo_scaled, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_k_opencl_cpp_export`, x, nu, expo_scaled, verbose)
}

#' @noRd
#' @keywords internal
.bessel_y_opencl <- function(x, nu, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_y_opencl_cpp_export`, x, nu, verbose)
}

#' @noRd
#' @keywords internal
.bessel_i_ex_opencl <- function(x, nu, expo, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_i_ex_opencl_cpp_export`, x, nu, expo, verbose)
}

#' @noRd
#' @keywords internal
.bessel_j_ex_opencl <- function(x, nu, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_j_ex_opencl_cpp_export`, x, nu, verbose)
}

#' @noRd
#' @keywords internal
.bessel_k_ex_opencl <- function(x, nu, expo, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_k_ex_opencl_cpp_export`, x, nu, expo, verbose)
}

#' @noRd
#' @keywords internal
.bessel_y_ex_opencl <- function(x, nu, verbose = FALSE) {
  .Call(`_nmathopencl_bessel_y_ex_opencl_cpp_export`, x, nu, verbose)
}

#' @noRd
#' @keywords internal
.imax2_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_imax2_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.imin2_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_imin2_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.fmax2_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_fmax2_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.fmin2_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_fmin2_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.sign_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_sign_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.fprec_opencl <- function(x, digits, verbose = FALSE) {
  .Call(`_nmathopencl_fprec_opencl_cpp_export`, x, digits, verbose)
}

#' @noRd
#' @keywords internal
.fround_opencl <- function(x, digits, verbose = FALSE) {
  .Call(`_nmathopencl_fround_opencl_cpp_export`, x, digits, verbose)
}

#' @noRd
#' @keywords internal
.fsign_opencl <- function(x, y, verbose = FALSE) {
  .Call(`_nmathopencl_fsign_opencl_cpp_export`, x, y, verbose)
}

#' @noRd
#' @keywords internal
.ftrunc_opencl <- function(x, verbose = FALSE) {
  .Call(`_nmathopencl_ftrunc_opencl_cpp_export`, x, verbose)
}

#' @noRd
#' @keywords internal
.r_check_user_interrupt_opencl <- function(n, verbose = FALSE) {
  .Call(`_nmathopencl_r_check_user_interrupt_opencl_cpp_export`, n, verbose)
}

#' @noRd
#' @keywords internal
.r_check_stack_opencl <- function(n, verbose = FALSE) {
  .Call(`_nmathopencl_r_check_stack_opencl_cpp_export`, n, verbose)
}


# =============================================================================
#  Phased Out (no R wrappers; C++ exports may still exist for compatibility)
#  - .rss_face_at_disp_cpp, .UB2_cpp
#  - Former RSS/UB2 minimization callbacks; active path uses closed-form C++ bounds
# =============================================================================
