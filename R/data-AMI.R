#' Amitriptyline overdose data
#'
#' Data with information on 17 overdoses of the drug amitriptyline
#'
#' @format This data frame contains the following columns:
#' \describe{
#'   \item{\code{TOT}}{total TCAD plasma level}
#'   \item{\code{AMI}}{amount of amitriptyline present in the TCAD plasma level}
#'   \item{\code{GEN}}{gender (male = 0, female = 1)}
#'   \item{\code{AMT}}{amount of drug taken at time of overdose}
#'   \item{\code{PR}}{PR wave measurement}
#'   \item{\code{DIAP}}{diastolic blood pressure}
#'   \item{\code{QRS}}{QRS wave measurement}
#' }
#'
#' @details
#' Each row is one overdose episode. Variables include total tricyclic antidepressant
#' level, amitriptyline component, gender, reported amount ingested, and ECG-related
#' measures (PR interval, QRS duration, diastolic blood pressure). The dataset is used
#' in package examples for binomial and related regression; see \insertCite{Dobson1990}{nmathopencl}
#' for analogous generalized linear modelling of clinical outcomes.
#'
#' @references
#' \insertAllCited{}
#'
#' @usage data(AMI)
#'
#' @example inst/examples/Ex_AMI.R
#'
#' @keywords datasets
#' @concept Bayesian Binomial Regression
"AMI"
