# Build data/Boston_centered.rda from MASS::Boston (mean-centered predictors).
#
# Run from package root:
#   Rscript data-raw/make_Boston_centered.R
#
# Requires MASS (listed in glmbayes Depends). The data-raw/ tree is in
# .Rbuildignore so this script is not part of the CRAN tarball.

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args) >= 1L) {
  normalizePath(args[[1]], winslash = "/", mustWork = TRUE)
} else {
  getwd()
}
owd <- setwd(root)
on.exit(setwd(owd), add = TRUE)

suppressPackageStartupMessages(library(MASS))
data("Boston", package = "MASS", envir = environment())

predictors <- setdiff(names(Boston), "medv")
Boston_centered <- Boston
Boston_centered[predictors] <- scale(Boston[predictors], center = TRUE, scale = FALSE)

out <- file.path(root, "data", "Boston_centered.rda")
save(Boston_centered, file = out, compress = "xz")
message("Wrote ", normalizePath(out, winslash = "/", mustWork = TRUE))
