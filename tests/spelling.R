if (requireNamespace("spelling", quietly = TRUE)) {
  spelling::spell_check_test(
    vignettes = TRUE,
    lang = "en-US",
    skip_on_cran = TRUE
  )
}
