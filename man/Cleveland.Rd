\name{Cleveland}
\docType{data}
\alias{Cleveland}

\title{Cleveland Heart Disease Dataset}

\description{
A cleaned version of the Cleveland heart disease dataset from the UCI Machine Learning Repository.
This version contains only complete cases and includes a derived binary outcome variable \code{hd}
indicating the presence (\code{"Yes"}) or absence (\code{"No"}) of heart disease.
}

\usage{
data("Cleveland")
}

\format{
A data frame with 297 observations and 15 variables:

\describe{
  \item{age}{Age in years (numeric).}
  \item{sex}{Sex (0 = female, 1 = male).}
  \item{cp}{Chest pain type (numeric code 1--4).}
  \item{trestbps}{Resting blood pressure (mm Hg).}
  \item{chol}{Serum cholesterol (mg/dl).}
  \item{fbs}{Fasting blood sugar > 120 mg/dl (1 = true, 0 = false).}
  \item{restecg}{Resting electrocardiographic results (numeric code).}
  \item{thalach}{Maximum heart rate achieved.}
  \item{exang}{Exercise-induced angina (1 = yes, 0 = no).}
  \item{oldpeak}{ST depression induced by exercise relative to rest.}
  \item{slope}{Slope of the peak exercise ST segment.}
  \item{ca}{Number of major vessels colored by fluoroscopy (0--3).}
  \item{thal}{Thalassemia status (numeric code).}
  \item{num}{Original UCI disease score (0--4).}
  \item{hd}{Binary heart disease indicator: \code{"No"} (num = 0) or \code{"Yes"} (num > 0).}
}
}

\source{
UCI Machine Learning Repository: Heart Disease Data Set.  
\url{https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/}
}

\examples{
# Load the dataset
data("Cleveland")

# ------------------------------------------------------------------
# OpenCL-accelerated Bayesian logistic regression example
# This example only runs if OpenCL is available.
# ------------------------------------------------------------------
if (has_opencl()) {

  # Prior setup for the full model
  ps <- Prior_Setup(
    hd ~ age + sex + cp + trestbps + chol +
      fbs + restecg + thalach + exang + oldpeak + slope + ca + thal,
    family = binomial(logit),
    data = Cleveland
  )

t_opencl <- system.time({
  fit <- glmb(
    hd ~ age + sex + cp + trestbps + chol +
      fbs + restecg + thalach + exang + oldpeak + slope + ca + thal,
    family       = binomial(link = "logit"),
    pfamily      = dNormal(mu = ps$mu, Sigma = ps$Sigma),
    data         = Cleveland,
    n            = 20000,
    Gridtype     = 2,
    use_parallel = TRUE,
    use_opencl   = TRUE,
    verbose      = TRUE
  )
})

t_opencl

  summary(fit)
}
}
\keyword{datasets}
\concept{Bayesian Binomial Regression}
