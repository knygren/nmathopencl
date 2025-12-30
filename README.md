# glmbayes

![GitHub release (latest by date)](https://img.shields.io/github/v/release/knygren/glmbayes?label=version)
![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/knygren/glmbayes/R-CMD-check.yaml?label=R%20CMD%20Check)

glmbayes provides independent and identically distributed (iid) samples for Bayesian Generalized Linear Models (GLMs).
Its primary interface, glmb(), serves as a Bayesian analogue to R's glm() function, supporting Gaussian, Poisson,
Binomial, and Gamma families under log-concave likelihoods. Sampling for most models is performed using accept-reject
methods based on likelihood subgradients (Nygren and Nygren, 2006). For Gaussian models, the package also includes
lmb(), a Bayesian counterpart to R's lm().

The package includes a rich set of supporting tools for prior specification, model diagnostics, and method functions
that mirror those for lm() and glm(). Most functions are extensively documented, and a comprehensive set of vignettes
are available to guide users through the package's capabilities.

The package is currently available on R-Universe, with plans for a future CRAN submission. For recent updates and planned enhancements, see
https://github.com/knygren/glmbayes/blob/main/NEWS.md

## Installation

To install the current development version (excluding OpenCL functionality):

install.packages("glmbayes",
                 repos = c("https://knygren.r-universe.dev",
                           "https://cloud.r-project.org"))

To install a version suitable for large models with GPU acceleration, follow the instructions in Chapter 12: "Large Models: GPU Acceleration Using OpenCL."

## Minimal Working Example

    library(glmbayes)

    # Dobson (1990), p. 93: Randomized Controlled Trial
    counts <- c(18,17,15,20,10,20,25,13,12)
    outcome <- gl(3,1,9)
    treatment <- gl(3,3)
    print(d.AD <- data.frame(treatment, outcome, counts))

    ## Classical glm
    glm.D93 <- glm(counts ~ outcome + treatment,
                   family = poisson())

    ## Bayesian glmb
    # Step 1: Set up prior
    ps <- Prior_Setup(counts ~ outcome + treatment, family = poisson())
    mu <- ps$mu
    V  <- ps$Sigma

    # Step 2: Fit using glmb
    glmb.D93 <- glmb(counts ~ outcome + treatment,
                     family = poisson(),
                     pfamily = dNormal(mu = mu, Sigma = V))

    summary(glmb.D93)

## Supported families, links, and pfamilies

As with the glm() function, models are specified by providing a symbolic description of the linear predictor
(using a formula) and a description of the error distribution (using a family and a link function). In addition, glmb()
also requires a prior specification, provided through a pfamily object. The available combinations of likelihood families,
link functions, and compatible pfamilies are:

| family                     | Available Link Functions           | Compatible pfamilies                                      |
|----------------------------|------------------------------------|------------------------------------------------------------|
| Gaussian                   | identity                           | dNormal, dGamma, dNormal_Gamma, dIndependent_Normal_Gamma |
| Poisson / Quasi-Poisson    | log                                | dNormal                                                    |
| Binomial / Quasi-Binomial  | logit, probit, cloglog             | dNormal                                                    |
| Gamma                      | log                                | dNormal, dGamma                                            |

More specifically, each pfamily constructor requires parameters associated with the prior. The available pfamilies and their usage signatures are:

- dNormal(mu, Sigma, dispersion = NULL)
- dGamma(shape, rate, beta, disp_lower = NULL, disp_upper = NULL)
- dNormal_Gamma(mu, Sigma, shape, rate)
- dIndependent_Normal_Gamma(
    mu,
    Sigma,
    shape,
    rate,
    max_disp_perc = 0.99,
    disp_lower = NULL,
    disp_upper = NULL
  )

To facilitate prior specification, the package provides a Prior_Setup() function, which extracts the needed prior parameters based on the same
symbolic model description and family specification used by glm(). By default, Prior_Setup() returns a reasonable prior specification
(described elsewhere), and optional arguments allow users to request alternative prior structures.

All supported models feature log-concave likelihoods, enabling efficient iid sampling via enveloping functions and
subgradient-based accept-reject algorithms (for models where other standard iid sampling algorithms are unavailable).

## Examples

Use example() to explore built-in examples for supported families and links:

    ## Bayesian linear regression
    example("lmb")

    ## Bayesian Generalized Linear Models
    example("glmb")

    ## Larger Binomial Model with GPU Acceleration (requires OpenCL)
    example("Cleveland")

## Methodology

For generalized linear models where well known sampling methods are unavailable, sampling follows the
framework from Nygren and Nygren (2006), using likelihood subgradients to construct enveloping functions for
the posterior distribution. When the posterior is approximately normal, the expected number of draws per
acceptance is bounded as per that paper and as discussed in our vignettes.

## GPU Acceleration Using OpenCL

The implemented algorithms tend to have acceptable performance on CPUs up to around 10-14 dimensions.
For larger models, the envelope construction is embarrassingly parallel. To accelerate envelope construction
in such cases, the package provides optional GPU acceleration using OpenCL. This requires that users have
GPU enabled machines and an OpenCL installation. These features are discussed in more detail in two of
our vignettes.

## Vignettes

The glmbayes package includes a comprehensive set of vignettes organized into five major parts.
These vignettes guide users from introductory material through applied modeling, advanced topics,
and the underlying simulation methods that support the package.

### Part 1: An Introduction (Chapters 00-01)
Overview of the package, its design philosophy, and the basic workflow for
fitting Bayesian linear and generalized linear models. It introduces the core functions, model
objects, and the structure of the modeling interface.

### Part 2: Estimating Bayesian Linear Models (Chapters 02-04)
These chapters focus on Bayesian linear regression using the Gaussian family. Topics include
model fitting, prior construction, posterior summaries, predictions, and deviance residuals.
This part establishes the foundation for understanding the Bayesian GLM framework used throughout
the package.

### Part 3: Generalized Linear Models (Chapters 05-09)
This part presents Bayesian GLMs across the major likelihood families, including binomial,
quasi-binomial, Poisson, quasi-Poisson, and Gamma models. It covers model specification,
link functions, log-concavity, diagnostics, and interpretation of posterior results.

### Part 4: Advanced Topics (Chapters 10-12)
These chapters explore more complex modeling scenarios and computational strategies, such as
informative priors, hierarchical Bayesian models using two-block Gibbs sampling, models with
unknown dispersion parameters, and large-scale model fitting using GPU acceleration using OpenCL.

### Part 5: Simulation Methods and Technical Implementation (Appendix Chapters A1-A7)
This part documents the mathematical and algorithmic foundations of the package. Topics include
estimation procedures, likelihood subgradient densities, envelope construction, accept-reject
sampling, and technical reports on sampler design including implementation aspects for GPU acceleration using
OpenCL.

Together, these vignettes form a comprehensive reference that supports users at all levels, from first-time Bayesian GLM users to researchers interested in the mathematical and computational details behind the samplers.

## Feature Highlights

- S3 interface mirroring the structure of base glm()
- Accept-reject sampling for log-concave likelihoods
- Samplers for both fixed and variable dispersion
- Extensive vignettes to guide users through the package's capabilities
- Modular prior setup and checking tools

## Limitations

- Non-log-concave likelihoods are not currently supported
- Dispersion estimation requires a second sampler (rglmbdisp())

## Future Plans

- Full CRAN submission and expanded vignette documentation