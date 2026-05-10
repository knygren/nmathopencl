# Internal helper for scalar n validation
.validate_n_scalar <- function(n) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != as.integer(n)) {
    stop("`n` must be a non-negative integer scalar.")
  }
  as.integer(n)
}

# Internal helper for logical flags
.validate_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", name))
  }
}

# Internal helper for scalar numeric checks
.validate_scalar_num <- function(x, name, lower = -Inf, upper = Inf, open_lower = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be a single non-missing numeric value.", name))
  }
  if (open_lower) {
    if (!(x > lower && x <= upper)) {
      stop(sprintf("`%s` must be in (%s, %s].", name, lower, upper))
    }
  } else {
    if (!(x >= lower && x <= upper)) {
      stop(sprintf("`%s` must be in [%s, %s].", name, lower, upper))
    }
  }
}

# Internal helper for OpenCL call/fallback pattern
.opencl_try_or_fallback <- function(opencl_expr, fallback_expr, fallback, verbose, fn_name) {
  if (!has_opencl()) {
    if (fallback) {
      if (verbose) message(sprintf("[%s] OpenCL unavailable; using CPU fallback.", fn_name))
      return(fallback_expr())
    }
    stop("OpenCL is not available in this nmathopencl build.")
  }

  out <- tryCatch(opencl_expr(), error = function(e) e)
  if (inherits(out, "error")) {
    if (fallback) {
      if (verbose) {
        message(sprintf("[%s] OpenCL call failed; using CPU fallback.", fn_name))
        message(out$message)
      }
      return(fallback_expr())
    }
    stop(out$message, call. = FALSE)
  }
  out
}
