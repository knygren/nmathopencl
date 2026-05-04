 #' Plot posterior draws for objects of class `glmb`.
 #'
 #' This converts `x$coefficients` to a `coda::mcmc` object. If `x$dispersion` is a
 #' draw vector (length equal to the number of draws), it is appended and plotted too.
 #'
 #' @param x Object inheriting from class `glmb`.
 #' @param which One of `"coefficients"`, `"dispersion"`, or `"both"`.
 #' @param ... Forwarded to `coda::plot.mcmc`.
 #' @return Invisibly `NULL`.
 #' @seealso \code{\link{glmb}}, \code{\link{nmathopencl-package}}; \code{\link{rglmb}}, \code{\link{rlmb}},
 #'   \code{\link{lmb}}; \code{\link[coda]{plot.mcmc}};
 #'   \code{\link[stats]{plot.lm}} and \code{\link[stats]{termplot}} for classical diagnostic plots of \code{lm}/\code{glm} fits.
 #' @export
 #' @method plot glmb
 
plot.glmb <- function(x,
                       which = c("coefficients", "dispersion", "both"),
                       ...) {
  which <- match.arg(which)
  args <- list(...)
  
  # glmbayes draws are (intended to be) iid; default to density plots only.
  # Users can override via plot(obj, trace=..., density=...).
  if (!("trace" %in% names(args))) args$trace <- FALSE
  if (!("density" %in% names(args))) args$density <- TRUE
  
  if (is.null(x$coefficients)) {
    stop("plot.glmb: x$coefficients is missing.")
  }
  
  coef_draws <- as.matrix(x$coefficients)
  n <- nrow(coef_draws)
  if (n <= 0) stop("plot.glmb: x$coefficients has no draws (nrow == 0).")
  
  if (is.null(colnames(coef_draws))) {
    colnames(coef_draws) <- paste0("coef", seq_len(ncol(coef_draws)))
  }
  
  if (which %in% c("dispersion", "both")) {
    disp_draws <- x$dispersion
    
    ## Only plot dispersion if it looks like a draw vector (length == number of draws)
    if (!is.null(disp_draws) && is.vector(disp_draws) && length(disp_draws) == n) {
      draws <- cbind(coef_draws, dispersion = disp_draws)
    } else {
      if (which == "dispersion") {
        stop("plot.glmb: x$dispersion is not a draw vector of length n (skipping dispersion).")
      }
      warning("plot.glmb: x$dispersion is not a draw vector of length n; plotting coefficients only.")
      draws <- coef_draws
    }
  } else {
    draws <- coef_draws
  }
  
  mcmc_obj <- coda::mcmc(draws)
  do.call(plot, c(list(mcmc_obj), args))
}

