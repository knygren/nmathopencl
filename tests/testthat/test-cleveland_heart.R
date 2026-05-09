test_that("Bayesian binomial-logit regression-OpenCL", {
  skip_if(!has_opencl(), "OpenCL not available")
    # Skip on CRAN to avoid long runtime / external data fetch
  skip_on_cran()
  
  ## Bundled cleaned UCI Cleveland data (see ?Cleveland); avoid fetching the
  ## raw UCI URL in tests — archive paths often move or block non-browser clients.
  df <- Cleveland
  
  # Prior setup
  ps <- Prior_Setup(hd ~ age + sex + cp + trestbps + chol +
                      fbs + restecg + thalach + exang + oldpeak + slope + ca + thal,
                    family = binomial(logit),
                    data = df)
  
  mu <- ps$mu
  sigma <- ps$Sigma
  
  # Fit Bayesian GLM with OpenCL (temporarily serial for debugging)
  glmb_hd <- glmb(
    hd ~ age + sex + cp + trestbps + chol +
      fbs + restecg + thalach + exang + oldpeak + slope + ca + thal,
    family  = binomial(link = "logit"),
    pfamily = dNormal(mu = mu, Sigma = sigma),
    data    = df,
    n       = 1,
    # n       = 10000,
    Gridtype = 2,
    use_parallel = FALSE,
    # use_parallel = TRUE,
    use_opencl   = TRUE
    ,verbose      = TRUE
    # ,verbose      = FALSE
  )
  
  # Test condition: average number of candidates per acceptance < 6
  avg_candidates <- mean(glmb_hd$iters)
  expect_true(avg_candidates < 6)
  

  
})

