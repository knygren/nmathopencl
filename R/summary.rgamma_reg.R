  #' Summarizing Bayesian gamma_reg Distribution Functions
#'
#' These functions are all \code{\link{methods}} for class \code{rGamma_reg} or \code{summary.rGamma_reg} objects.
#' 
#' @aliases 
#' summary.rGamma_reg
#' print.summary.rGamma_reg
#' @param object an object of class \code{"rGamma_reg"} for which a 
#' summary is desired.
#' @param x an object of class \code{"summary.rGamma_reg"} for which a printed output is desired.
#' @param digits the number of significant digits to use when printing.
#' @param \ldots Additional optional arguments
#' @return
#' \code{summary.rGamma_reg()} returns an object of class
#' \code{"summary.rGamma_reg"}, a list containing summaries of posterior
#' draws for the dispersion and precision parameters. Components include:
#' \item{call}{the matched call from the fitted object.}
#' \item{n}{number of posterior draws.}
#' \item{coefficients1}{matrix of prior means and standard deviations for
#' precision and dispersion.}
#' \item{coefficients}{matrix of posterior means, posterior standard
#' deviations, Monte Carlo errors, and empirical tail probabilities.}
#' \item{Percentiles}{matrix of posterior percentiles for dispersion draws.}
#' \item{implied_disp_point}{dispersion point estimate implied by the Gamma
#' prior on precision, computed as \code{rate / shape}.}
#'
#' \code{print.summary.rGamma_reg()} prints the summary object and returns
#' \code{x} invisibly.
#' @export
#' @rdname summary.rgamma_reg
#' @order 1
#' @method summary rGamma_reg


summary.rGamma_reg<-function(object,...){
  
  n <- length(object$dispersion)
  disp_draws <- as.numeric(object$dispersion)
  prec_draws <- 1 / disp_draws
  
  # Recover shape/rate from object; fallback to pfamily prior_list when needed
  shape <- object$Prior$shape
  rate  <- object$Prior$rate
  if (is.null(shape) || is.null(rate)) {
    if (!is.null(object$pfamily$prior_list$shape) && !is.null(object$pfamily$prior_list$rate)) {
      shape <- object$pfamily$prior_list$shape
      rate  <- object$pfamily$prior_list$rate
    }
  }
  
  if (is.null(shape) || is.null(rate)) {
    stop("Could not recover shape/rate for dGamma prior from object.")
  }
  
  # Prior moments on precision scale: tau = 1/dispersion ~ Gamma(shape, rate)
  prior_mean_prec <- shape / rate
  prior_sd_prec   <- sqrt(shape) / rate
  
  # Implied prior moments on dispersion scale: phi = 1/tau
  prior_mean_disp <- if (shape > 1) rate / (shape - 1) else NA_real_
  prior_sd_disp   <- if (shape > 2) rate / ((shape - 1) * sqrt(shape - 2)) else NA_real_
  
  # Posterior summaries
  post_mean_prec <- mean(prec_draws)
  post_sd_prec   <- sd(prec_draws)
  post_mc_prec   <- post_sd_prec / sqrt(n)
  
  post_mean_disp <- mean(disp_draws)
  post_sd_disp   <- sd(disp_draws)
  post_mc_disp   <- post_sd_disp / sqrt(n)
  
  # Two-sided empirical tail probabilities vs prior means (on matching scales)
  test_prec <- append(prec_draws, prior_mean_prec)
  rank_prec <- rank(test_prec)[n + 1]
  p_prec <- rank_prec / (n + 1)
  p_tail_prec <- min(p_prec, 1 - p_prec)
  
  if (is.finite(prior_mean_disp)) {
    test_disp <- append(disp_draws, prior_mean_disp)
    rank_disp <- rank(test_disp)[n + 1]
    p_disp <- rank_disp / (n + 1)
    p_tail_disp <- min(p_disp, 1 - p_disp)
  } else {
    p_tail_disp <- NA_real_
  }
  
  Tab1 <- rbind(
    "precision (1/dispersion)" = c(prior_mean_prec, prior_sd_prec),
    "dispersion"               = c(prior_mean_disp, prior_sd_disp)
  )
  colnames(Tab1) <- c("Prior.Mean", "Prior.Sd")
  
  TAB <- rbind(
    "precision (1/dispersion)" = c(post_mean_prec, post_sd_prec, post_mc_prec, p_tail_prec),
    "dispersion"               = c(post_mean_disp, post_sd_disp, post_mc_disp, p_tail_disp)
  )
  colnames(TAB) <- c("Post.Mean", "Post.Sd", "MC.Error", "Pr(tail)")
  
  # Keep posterior percentiles table for dispersion draws (core estimand in current API)
  percentiles <- quantile(disp_draws, probs = c(0.01, 0.025, 0.05, 0.5, 0.95, 0.975, 0.99))
  TAB2 <- rbind("dispersion" = as.numeric(percentiles))
  colnames(TAB2) <- c("1.0%", "2.5%", "5.0%", "Median", "95.0%", "97.5%", "99.0%")
  
  res<-list(call=object$call,
            n=n,
            coefficients1=Tab1,
            coefficients=TAB,
            Percentiles=TAB2,
            implied_disp_point = rate / shape
  )
  
  # Reuse summary.rglmb class
  
  class(res) <- "summary.rGamma_reg"  
  res
  
}


#' @export
#' @rdname summary.rgamma_reg
#' @order 2
#' @method print summary.rGamma_reg


print.summary.rGamma_reg <- function(x, digits = max(3, getOption("digits") - 3), ...) {
  
  ## --- Call ---
  cat("Call\n")
  print(x$call)
  cat("\n")

  ## --- Helpful implied point estimate from precision prior ---
  # Printed early since it is often used to interpret the dispersion scale before
  # inspecting the prior table (e.g. when dispersion mean is undefined).
  cat("Implied dispersion point estimate from precision prior (1/E[1/dispersion]):",
      round(x$implied_disp_point, digits), "\n\n")
  
  ## --- Prior Estimates ---
  cat("Prior Estimates with Standard Deviations\n\n")
  print(round(x$coefficients1, digits))
  cat("\n")
  
  ## --- Posterior Estimates ---
  cat("Bayesian Estimates Based on", x$n, "iid draws\n\n")
  
  # Extract posterior table
  TAB <- round(x$coefficients, digits)
  
  # Compute significance stars
  pvals <- x$coefficients[, "Pr(tail)"]
  stars <- ifelse(
    is.na(pvals), "",
    ifelse(pvals < 0.001, "***",
           ifelse(pvals < 0.01,  "**",
                  ifelse(pvals < 0.05,  "*",
                         ifelse(pvals < 0.1,   ".", " "))))
  )
  
  # Build final table with stars
  TAB2 <- cbind(TAB, Signif = stars)
  
  print(TAB2)
  cat("---\n")
  cat("Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n\n")
  
  ## --- Percentiles ---
  cat("Distribution Percentiles\n\n")
  print(round(x$Percentiles, digits))
  cat("\n")
  
  ## --- Dispersion summary ---
  disp.mean <- x$coefficients["dispersion", "Post.Mean"]
  cat("Expected Mean dispersion:", round(disp.mean, digits), "\n")
  cat("Sq.root of Expected Mean dispersion:", round(sqrt(disp.mean), digits), "\n\n")
  
  invisible(x)
}

