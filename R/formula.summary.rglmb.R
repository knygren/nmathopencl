#' Model Formulae
#'
#' This function is a method function for the \code{"summary.rglmb"} class used to 
#' Extract a formulae for the objective and the family
#' @param x an object of class \code{summary.rglmb}, typically the result of a call to \code{\link{summary.rglmb}}
#' @param ... further arguments to or from other methods
#' @return The function returns model formulae
#' @seealso \code{\link{rglmb}}, \code{\link{summary.rglmb}}; \code{\link{glmb}}, \code{\link{nmathopencl-package}};
#'   \code{\link{rlmb}}, \code{\link{lmb}}; \code{\link[stats]{formula}}.
#' @export
#' @method formula summary.rglmb



formula.summary.rglmb<-function(x,...){
  
  z=x
  y=z$y
  x=z$x
  return(formula(glm(y~x-1,family=family(z))))
  
}