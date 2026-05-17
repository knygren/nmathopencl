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

# Encode logical NA / TRUE / FALSE for C++ (int): 0 = serial, 1 = parallel, 2 = auto
.encode_opencl_parallel <- function(x) {
  if (length(x) != 1L) {
    stop("`opencl_parallel` must have length 1.")
  }
  if (isTRUE(x)) {
    return(1L)
  }
  if (identical(x, FALSE)) {
    return(0L)
  }
  if (is.logical(x) && is.na(x)) {
    return(2L)
  }
  stop("`opencl_parallel` must be TRUE, FALSE, or NA.")
}

.validate_p_stage1_tails <- function(lower.tail, log.p) {
  if (!is.logical(lower.tail) || any(is.na(lower.tail))) {
    stop("`lower.tail` must be logical with no missing values.", call. = FALSE)
  }
  if (!is.logical(log.p) || any(is.na(log.p))) {
    stop("`log.p` must be logical with no missing values.", call. = FALSE)
  }
}

.p_stage1_recycle_len <- function(lens, stats_help_topic) {
  len <- max(lens)
  if (len == 0L) {
    return(0L)
  }
  if (len > 0L && any(lens == 0L)) {
    stop(
      "arguments of length zero cannot be recycled when the output length is positive (see ",
      stats_help_topic,
      ").",
      call. = FALSE
    )
  }
  if (len > .Machine$integer.max) {
    stop("arguments are too long for the OpenCL interface.", call. = FALSE)
  }
  len
}
