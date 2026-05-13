#' Envelope Evaluation Utilities
#'
#' @description
#' Core utilities for envelope-based posterior simulation using GPU-accelerated
#' OpenCL kernels. These functions support the construction and evaluation of
#' log-likelihood envelopes used in rejection sampling, and serve as an example
#' of how downstream packages can build custom OpenCL kernels on top of the
#' ported nmath routines in \pkg{nmathopencl}.
#'
#' @references
#' \insertAllCited{}
#'
#'
#' @name glmbayesEnvelopeExample
NULL




#' Return family functions used during simulation and post processing
#'
#' This function takes as input a \code{\link{family}} object and returns a 
#' set of functions that are used during simulation and summarization of models 
#' using the simulation functions in this package.
#' 
#' @name Ex_glmbfamfunc
#' @aliases
#' Ex_glmbfamfunc
#' print.Ex_glmbfamfunc
#' @param family an object of class \code{\link{family}}
#' @param x an object of class \code{"Ex_glmbfamfunc"} for which a printed output is desired.
#' @param \ldots additional optional arguments
#' @return A list (class \code{"Ex_glmbfamfunc"}) whose first four components are **always**
#'   present for every supported \code{family} and \code{link}. The names \code{f1}--\code{f4}
#'   are stable: they mean the same roles across families (only the internal formulas change).
#'   \describe{
#'   \item{\code{f1}}{Negative log-likelihood as a function of coefficients \code{b}
#'     (arguments typically \code{b}, \code{y}, \code{x}, optional \code{alpha}, \code{wt}).}
#'   \item{\code{f2}}{Negative log-posterior (likelihood plus Normal prior quadratic form in
#'     \code{b} with precision \code{P} and mean \code{mu}).}
#'   \item{\code{f3}}{Gradient of \code{f2} with respect to \code{b} (same argument pattern as \code{f2}).}
#'   \item{\code{f4}}{Deviance-related quantity (twice negative log-likelihood contrast vs.\
#'     saturated model, with a \code{dispersion} argument for quasi-families); used in DIC-style summaries.}
#'   \item{\code{f7}}{Family-specific matrix: weighted sum of outer products of predictor rows,
#'     i.e.\ a curvature / expected negative Hessian of the log-likelihood w.r.t.\ \code{b}
#'     at the supplied \code{b} (used e.g.\ for post-processing of \code{glmb} fits).}
#'   }
#'   Slots \code{f5} and \code{f6} are **not** returned: they were reserved for alternate or
#'   C++-aligned likelihood/posterior routines and remain commented out in the implementation
#'   (only \code{f1}, \code{f2}, \code{f3}, \code{f4}, and \code{f7} are assigned in the returned list).
#' @details
#'   For simulation, many code paths now pass closed-form objectives into C++ directly; \code{Ex_glmbfamfunc}
#'   remains the canonical R closure bundle for the same likelihood/prior/deviance quantities and for
#'   post-processing of model results.
#' @export
#' @rdname Ex_glmbfamfunc
#' @order 1

Ex_glmbfamfunc<-function(family){
  
  # need to add handling for offsets 
  
  # f1-(negative)Log-Likelihood function
  # f2-(negative)Log-Posterior density
  # f3-(negative) Gradient for Log-Posterior density 
  # f4-Deviance function (note multiplies the difference in two times log-likelihood by dispersion)
  
  if(family$family=="gaussian")
  {
    f1<-function(b,y,x,alpha=0,wt=1){
      Xb<-alpha+x%*%b
      -sum(dnorm(y, mean=Xb,sd=sqrt(1/wt),log=TRUE))
    }
    f2<-function(b,y,x,mu,P,alpha=0,wt=1){
      Xb<-alpha+x%*%b
      -sum(dnorm(y, mean=Xb,sd=sqrt(1/wt),log=TRUE))+0.5*t((b-mu))%*%P%*%(b-mu)
    }
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      l2<-length(y)
      ltemp<-length(wt)
      yxb2<-NULL
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      xb<-alpha+x%*%b-y
      yXb2<-P%*%(b-mu)+t(x)%*%(Ptemp%*%xb)
      yXb2
    }
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      
      ## adds 2*log-likelihood at mean=y which measn this is 2* Negative log-likelihood difference from saturated
      ## Multiplication by dispersion likely is/was incorrect
      ## As long as single value for the parameters and dispersion, can do the below
      
      #dispersion*(2*f1(b,y,x,alpha,wt)+2*sum(dnorm(y, mean=y,sd=sqrt(1/wt),log=TRUE)))
      2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dnorm(y, mean=y,sd=sqrt(dispersion/wt),log=TRUE))
      
    }
    
    # Edit This
    #	f5<-f2_gaussian
    #	f6<-f3_gaussian
    
    f7<-function(b,y,x,mu,P,alpha=0,wt=1){
      l2<-length(y)
      ltemp<-length(wt)
      yxb2<-NULL
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      Pout<-t(x)%*%(Ptemp)%*%x
      Pout
    }
    
    
    
    
    
    
  }
  
  # Check if Poisson weight should be outside or inside function
  
  
  if(family$family=="poisson"||family$family=="quasipoisson")
  {
    f1<-function(b,y,x,alpha=0,wt=1){
      lambda<-t(exp(alpha+x%*%b))
      #-sum(dpois(y, lambda,log=TRUE)*wt)
      -sum(dpois2(y, lambda,log=TRUE)*wt)
      
      
      
    }
    f2<-function(b,y,x,mu,P,alpha=0,wt=1){
      lambda<-t(exp(alpha+x%*%b))
      #-sum(dpois(y, lambda,log=TRUE)*wt)+0.5*t((b-mu))%*%P%*%(b-mu)
      -sum(dpois2(y, lambda,log=TRUE)*wt)+0.5*t((b-mu))%*%P%*%(b-mu)
    }
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      -t(x)%*%((y-exp(alpha+x%*%b))*wt)+P%*%(b-mu)
      
    }
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      #dispersion*(2*f1(b,y,x,alpha,wt)+2*sum(dpois(y, y,log=TRUE)*wt))
      (2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dpois2(y, y,log=TRUE)*(wt/dispersion)))
    }
    
    f7<-function(b, y, x, mu, P, alpha = 0, wt = 1) {
      l2 <- length(y)
      l1 <- length(b)
      ltemp <- length(wt)
      
      # Construct diagonal weight matrix
      if (ltemp == 1) {
        Ptemp <- wt * diag(l2)
      } else {
        Ptemp <- diag(wt)
      }
      
      # Compute expected counts
      mu_i <- exp(alpha + x %*% b)
      
      # Initialize output matrix
      Pout <- matrix(0, nrow = l1, ncol = l1)
      
      # Loop over observations
      for (i in 1:l2) {
        xi <- x[i, , drop = FALSE]  # row as matrix
        weight_i <- Ptemp[i, i] * mu_i[i]
        Pout <- Pout + weight_i * (t(xi) %*% xi)
      }
      
      Pout
    }
    
    
    
    
  }
  
  if(family$family %in%  c("binomial","quasibinomial") && family$link=="logit")
  {
    f1<-function(b,y,x,alpha=0,wt=1){
      lambda<-t(exp(alpha+x%*%b))
      p<-lambda/(1+lambda)
      -sum(dbinom(round(wt*y),round(wt), p,log=TRUE))
    }
    f2<-function(b,y,x,mu,P,alpha=0,wt=1){
      lambda<-t(exp(alpha+x%*%b))
      p<-lambda/(1+lambda)
      -sum(dbinom(round(wt*y),round(wt),p,log=TRUE))+0.5*t((b-mu))%*%P%*%(b-mu)
    }
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      p<-1/(1+t(exp(-alpha-x%*%b)))
      t(x)%*%((t(p)-y)*wt)+P%*%(b-mu)
    }
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      #dispersion*(2*f1(b,y,x,alpha,wt)+2*sum(dbinom(round(wt*y),round(wt),y,log=TRUE)))
      (2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dbinom(round((wt/dispersion)*y),round(wt/dispersion),y,log=TRUE)))
    }
    
    f7<-function(b,y,x,mu,P,alpha=0,wt=1){
      
      l2<-length(y)
      l1<-length(b)
      ltemp<-length(wt)
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      
      p<-1/(1+t(exp(-alpha-x%*%b)))
      
      
      Pout<-matrix(0,nrow=l1,ncol=l1)
      
      for(i in 1:l2){
        Pout<-Pout+Ptemp[i,i]*p[i]*(1-p[i])*x[i,]%*%t(x[i,])
      }
      
      Pout
    }
    
    
  }
  
  if(family$family %in%  c("binomial","quasibinomial") && family$link=="probit")
  {
    f1<-function(b,y,x,alpha=0,wt=1){
      p<-pnorm(alpha+x%*%b)
      -sum(dbinom(round(wt*y),round(wt), p,log=TRUE))
    }
    f2<-function(b,y,x,mu,P,alpha=0,wt=1){
      p<-pnorm(alpha+x%*%b)
      -sum(dbinom(round(wt*y),round(wt),p,log=TRUE))+0.5*t((b-mu))%*%P%*%(b-mu)
    }
    
    
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      p1<-pnorm(alpha+x%*%b)
      p2<-pnorm(-alpha-x%*%b)
      -t(x)%*%as.matrix(((y*dnorm(alpha+x%*%b)/p1)-(1-y)*dnorm(alpha+x%*%b)/p2)*wt)+P%*%(b-mu)
    }
    
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      #dispersion*(2*f1(b,y,x,alpha,wt)+2*sum(dbinom(round(wt*y),round(wt),y,log=TRUE)))
      (2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dbinom(round((wt/dispersion)*y),round(wt/dispersion),y,log=TRUE)))
    }
    
    f7<-function(b,y,x,mu,P,alpha=0,wt=1){
      
      l2<-length(y)
      l1<-length(b)
      ltemp<-length(wt)
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      
      p<-1/(1+t(exp(-alpha-x%*%b)))
      
      
      Pout<-matrix(0,nrow=l1,ncol=l1)
      
      for(i in 1:l2){
        Pout<-Pout+Ptemp[i,i]*p[i]*(1-p[i])*x[i,]%*%t(x[i,])
      }
      
      Pout
    }
    
    
    
    
    
  }
  if(family$family %in%  c("binomial","quasibinomial") && family$link=="cloglog")
  {
    f1<-function(b,y,x,alpha=0,wt=1){
      Xb<-alpha+x%*%b
      p<-1-exp(-exp(Xb))
      -sum(dbinom(round(wt*y),round(wt), p,log=TRUE))
    }
    f2<-function(b,y,x,mu,P,alpha=0,wt=1){
      Xb<-alpha+x%*%b
      p<-1-exp(-exp(Xb))
      -sum(dbinom(round(wt*y),round(wt),p,log=TRUE))+0.5*t((b-mu))%*%P%*%(b-mu)
    }
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      Xb<-alpha+x%*%b
      p1<-1-exp(-exp(Xb))
      p2<-exp(-exp(Xb))
      atemp<-exp(Xb-exp(Xb))
      -t(x)%*%as.matrix(((y*atemp/p1)-(1-y)*atemp/p2)*wt)+P%*%(b-mu)
    }
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      dispersion*(2*f1(b,y,x,alpha,wt)+2*sum(dbinom(round(wt*y),round(wt),y,log=TRUE)))
      (2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dbinom(round((wt/dispersion)*y),round(wt/dispersion),y,log=TRUE)))
    }
    
    f7<-function(b,y,x,mu,P,alpha=0,wt=1){
      
      l2<-length(y)
      l1<-length(b)
      ltemp<-length(wt)
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      
      p<-1/(1+t(exp(-alpha-x%*%b)))
      
      
      Pout<-matrix(0,nrow=l1,ncol=l1)
      
      for(i in 1:l2){
        Pout<-Pout+Ptemp[i,i]*p[i]*(1-p[i])*x[i,]%*%t(x[i,])
      }
      
      Pout
    }
    
    
    
  }
  if(family$family=="Gamma" && family$link=="log")
  {
    
    f1<-function(b,y,x,alpha=0,wt=1){
      mu<-t(exp(alpha+x%*%b))
      disp2<-1/wt
      -sum(dgamma(y,shape=1/disp2,scale=mu*disp2,log=TRUE))
    }
    
    #  f1<-f1_gamma
    f2 <- function(b, y, x, mu, P, alpha = 0, wt = 1) {
      
      eta    <- alpha + x %*% b
      scale2 <- t(exp(eta - log(wt)))
      disp2  <- 1 / wt
      
      -sum(dgamma(y, shape = 1/disp2, scale = scale2, log = TRUE)) +
        0.5 * t((b - mu)) %*% P %*% (b - mu)
    }
    
    
    f3<-function(b,y,x,mu,P,alpha=0,wt=1){
      mu2<-t(exp(alpha+x%*%b))
      t(x)%*%(t(1-y/mu2)*wt)+P%*%(b-mu)
    }
    
    f4<-function(b,y,x,alpha=0,wt=1,dispersion=1){
      disp2<-1/(wt/dispersion)
      
      (2*f1(b,y,x,alpha,wt/dispersion)+2*sum(dgamma(y,shape=1/disp2,scale=y*disp2,log=TRUE)))
      
    }
    
    f7<-function(b,y,x,mu,P,alpha=0,wt=1){
      
      l2<-length(y)
      l1<-length(b)
      ltemp<-length(wt)
      if(ltemp==1){
        Ptemp<-wt*diag(l2)
      }
      else {
        Ptemp<-diag(wt)      
      }
      
      p<-1/(1+t(exp(-alpha-x%*%b)))
      
      
      Pout<-matrix(0,nrow=l1,ncol=l1)
      
      for(i in 1:l2){
        Pout<-Pout+Ptemp[i,i]*p[i]*(1-p[i])*x[i,]%*%t(x[i,])
      }
      
      Pout
    }
    
    
    
  }	
  
  out=list(f1=f1,f2=f2,f3=f3,f4=f4,
           #f5=f5,
           #f6=f6,
           f7=f7)
  
  out$call<-match.call()
  
  class(out)<-"Ex_glmbfamfunc"
  out
  
  
}


#' @rdname Ex_glmbfamfunc
#' @order 2
#' @method print Ex_glmbfamfunc
#' @export


print.Ex_glmbfamfunc<-function(x,...)
{
  cat("Call:\n")
  print(x$call)
  cat("\nNegative Log-Likelihood Function:\nf1<-")
  print(x$f1)
  cat("\n(Negative Log-Posterior Function:\nf2<-")
  print(x$f2)
  cat("\nNegative Log-Posterior Gradient Function:\nf3<-")
  print(x$f3)
  cat("\nDeviance Function:\nf4<-")
  print(x$f4)
  
  
}


#' Standardize A Non-Gaussian Model
#'
#' Standardizes a Non-Gaussian Model prior to Envelope Creation
#' @param y a vector of observations of length m
#' @param x a design matrix of dimension m*p
#' @param P a positive-definite symmetric matrix specifying the prior precision matrix of the variables.
#' @param bstar a matrix containing the posterior mode from an optimization step
#' @param A1 a matrix containing the posterior precision matrix at the posterior mode
#' @return A list with the following components
#' \item{bstar2}{Standardized Posterior Mode}
#' \item{A}{Standardized Data Precision Matrix}
#' \item{x2}{Standardized Design Matrix}
#' \item{mu2}{Standardized Prior Mean vector}
#' \item{P2}{Standardized Precision Matrix Added to log-likelihood}
#' \item{L2Inv}{A matrix used when undoing the first step in standardization described below}
#' \item{L3Inv}{A matrix used when undoing the second step in standardization described below}
#' @details This functions starts with basic information about the model in the argument list and then
#' uses the following steps to further standardize the model (the model is already assumed to have a 0 prior mean vector
#' when this step is applied).
#' 
#' 1) An eigenvalue composition is applied to the posterior precision matrix, and the model is (as an interim step)
#' standardized to have a posterior precision matrix equal to the identity matrix. Please note that this means
#' that the prior precision matrix after this step is \code{"smaller"} than the identity matrix.
#' 
#' 
#' 2) A diagonal matrix epsilon is pulled out from the standardized prior precision matrix so that the remaining
#' part of the prior precision matrix still is positive definite. That part is then treated as part of the likelihood
#' for the rest of the standardization and simulation and only the part connected to epsilon is treated as part of the prior. 
#' Note that the exact epsilon chosen seems not to matter. Hence there are many possible ways of doing this 
#' standardization and future versions of this package may tweak the current approach 
#' if it helps improve numerical accuracy or acceptance rates.
#' 
#' 
#' 3) The model is next standardized (using a second eigenvalue decomposition) so that the prior (i.e., the portion connected to epsilon) is the identity 
#' matrix. The standardized model then simutaneously has the feature that the prior precision matrix is the 
#' identity matrix and that the data precision A (at the posterior mode) is a diagonal matrix. Hence the variables
#' in the standardized model are approximately independent at the posterior mode.
#' 
#' The steps here are based on the procedure described in \insertCite{Nygren2006}{nmathopencl}.
#'
#' @references
#' \insertAllCited{}
#' @importFrom Rdpack reprompt
#' @export


Ex_glmb_Standardize_Model<-function(y, x, P, bstar, A1){
  
  return(.glmb_Standardize_Model_cpp(y, x, P, bstar, A1))
  
}


#' Envelope Sizing and Optimization
#'
#' \code{Ex_EnvelopeSize()} is the high-level entry point that constructs
#' per-dimension grids and expected draw counts, while \code{Ex_EnvelopeOpt()}
#' performs the adaptive optimization used when \code{Gridtype = 2}.
#'
#' These functions implement the grid sizing logic used in envelope construction
#' for rejection sampling. They make use of the theory described in
#' \insertCite{Nygren2006}{nmathopencl} and the general implementation outlined in
#' \insertCite{glmbayesSimmethods}{nmathopencl}. 
#' 
#' @param a Numeric vector of diagonal precisions for the log-likelihood
#'   (posterior precision is \eqn{1 + a_i}).
#' @param G1 Numeric matrix of candidate grid points (3 * l1).
#' @param Gridtype Integer code controlling grid sizing logic:
#'   \itemize{
#'     \item 1 = static threshold test
#'     \item 2 = adaptive optimization via \code{Ex_EnvelopeOpt()}
#'     \item 3 = always three-point grid
#'     \item 4 = always single-point grid
#'   }
#' @param n Integer; number of posterior draws to generate (used for grid sizing).
#' @param n_envopt Integer; effective sample size passed to \code{Ex_EnvelopeOpt}.
#'   Defaults to -1, which means "use n".
#' @param use_opencl Logical; if \code{TRUE}, attempt GPU acceleration.
#' @param verbose Logical; if \code{TRUE}, print progress messages.
#'
#'   (default 1). When >1, envelope build cost is scaled down to reflect
#'   parallel construction.
#'
#' @section Gridtype Logic and Candidates per Draw:
#'
#' The envelope sizing logic follows the analysis of \insertCite{Nygren2006}{nmathopencl}.
#'
#' \describe{
#'
#'   \item{Gridtype 1: Static Threshold}{
#'     For each dimension \eqn{i}, if
#'     \eqn{\sqrt{1 + a_i} \leq 2/\sqrt{\pi} \approx 1.128379},
#'     then a single tangent at the posterior mode suffices.
#'     Expected candidates per draw in that dimension:
#'     \eqn{\sqrt{1 + a_i}}. Otherwise, a symmetric three-point envelope is used at
#'     \eqn{(\theta^\star_i - \omega_i, \theta^\star_i, \theta^\star_i + \omega_i)},
#'     with expected candidates per draw bounded above by
#'     \eqn{2/\sqrt{\pi}}.
#'   }
#'
#'   \item{Gridtype 2: Adaptive Optimization}{
#'     Each dimension is assigned either a single-point or three-point envelope
#'     by minimizing
#'     \deqn{T_\mathrm{total}(g_i) = T_\mathrm{build}(g_i) + T_\mathrm{sample}(n, acc_i(g_i)).}
#'     The optimizer balances build cost (grows with number of tangents) against
#'     sampling cost (decreases as acceptance improves).
#'     Expected candidates per draw:
#'     \eqn{\prod_j \mathrm{scaleest}_{i,j}}, where each factor is either
#'     \eqn{\sqrt{1+a_j}} (single-point) or \eqn{2/\sqrt{\pi}} (three-point),
#'     depending on the optimization outcome.
#'   }
#'
#'   \item{Gridtype 3: Always Three-Point}{
#'     Every dimension uses a symmetric three-point envelope.  
#'     Expected candidates per draw:
#'     \deqn{\left(\tfrac{2}{\sqrt{\pi}}\right)^k}
#'     for \eqn{k} dimensions, as shown in Theorem 3 of
#'     \insertCite{Nygren2006}{nmathopencl}.
#'   }
#'
#'   \item{Gridtype 4: Always Single-Point}{
#'     Every dimension uses a single tangent at the posterior mode.  
#'     Expected candidates per draw:
#'     \deqn{\prod_{i=1}^k \sqrt{1 + a_i}}
#'     (Example 1 in \insertCite{Nygren2006}{nmathopencl}).
#'   }
#'
#' }
#'
#' @details
#' \code{Ex_EnvelopeSize()} returns the constructed grid (\code{G2}),
#' index vectors (\code{GIndex1}), expected draw count (\code{E_draws}),
#' and the per-dimension grid index.  
#'
#' \code{Ex_EnvelopeOpt()} implements the adaptive optimization used in
#' \code{Gridtype = 2}, ranking dimensions by posterior variance and
#' promoting them to three-point tangents when the tradeoff is favorable.
#'
#' @return
#' \describe{
#'   \item{\code{Ex_EnvelopeSize()}}{A list with components \code{G2}, \code{GIndex1},
#'   \code{E_draws}, and \code{gridindex}.}
#'   \item{\code{Ex_EnvelopeOpt()}}{An integer vector of length \eqn{l1} with entries
#'   1 (single-point) or 3 (three-point).}
#' }
#'
#' @seealso \code{\link{Ex_EnvelopeEval}} for evaluating these grids.
#' Vignettes: \insertCite{glmbayesSimmethods,glmbayesChapterA08}{nmathopencl}.
#'
#' @references
#' \insertAllCited{}
#' @export
#' @usage Ex_EnvelopeSize(a, G1, Gridtype = 2L, n = 1000L, n_envopt = -1,
#'                     use_opencl = FALSE, verbose = FALSE)
#' @rdname Ex_EnvelopeSize
#' @export
Ex_EnvelopeSize <- function(a,
                         G1,
                         Gridtype   = 2L,
                         n          = 1000L,   # <-- updated default
                         n_envopt   = -1,
                         use_opencl = FALSE,
                         verbose    = FALSE) {
  .EnvelopeSize_cpp(a, G1, Gridtype, n, n_envopt, use_opencl, verbose)
}


#' Evaluate Negative Log-Likelihood and Gradients
#'
#' @name Ex_EnvelopeEval
NULL

#'
#' The lower-level helpers `f2_f3_non_opencl` and `f2_f3_opencl`
#' are internal C++ kernels used by the CPU and OpenCL backends.
#' The internal routine `run_opencl_pilot` benchmarks OpenCL performance
#' on a pilot subset of the grid to estimate runtime before full evaluation.
#'
#' These functions implement the grid evaluation logic used in envelope
#' construction for rejection sampling. They make use of the theory described
#' in \insertCite{Nygren2006}{nmathopencl} and the general implementation outlined
#' in \insertCite{glmbayesSimmethods}{nmathopencl}.
#'
#' @param G4 Numeric matrix of parameter values (parameters * grid points).
#' @param y Numeric response vector.
#' @param x Numeric design matrix.
#' @param mu Numeric matrix of offsets or prior means.
#' @param P Numeric matrix representing the portion of the prior precision
#'   shifted into the likelihood.
#' @param alpha Numeric offset vector of length `m`
#' @param wt Numeric vector of weights.
#' @param family Character string; model family (e.g. \code{"gaussian"}).
#' @param link Character string; link function (e.g. \code{"identity"}).
#' @param use_opencl Logical; if \code{TRUE}, attempt OpenCL acceleration.
#' @param verbose Logical; if \code{TRUE}, print diagnostic output.
#' @details
#' The evaluation workflow has several layers:
#' **1. High-level dispatch (`Ex_EnvelopeEval`)**
#'
#' * `Ex_EnvelopeEval()` is the user-facing entry point. It accepts a grid of
#'   parameter values (`G4`) and the data (`y`, `x`, `mu`, `P`, `alpha`, `wt`).
#' * If the grid is large (>= 14 columns), it first calls
#'   `run_opencl_pilot` to benchmark OpenCL performance and optionally
#'      report estimated runtime.
#' * It then dispatches to either the CPU or GPU backend:
#'   - If `use_opencl = TRUE` and the family is not `"gaussian"`, it calls
#'     `f2_f3_opencl` (an internal C++ kernel).
#'   - Otherwise, it calls `f2_f3_non_opencl` (the CPU kernel).
#'   
#' **2. CPU backend (`f2_f3_non_opencl`)**
#'
#' * This function evaluates the negative log-likelihood and gradients using
#'   standard CPU routines.
#' * It inspects the `family` and `link` arguments and routes to the correct
#'   pair of kernels (`f2_*` for the likelihood, `f3_*` for the gradient).
#' * For example:
#'   - `"binomial"` with `"logit"` calls `f2_binomial_logit()` and
#'     `f3_binomial_logit()`.
#'   - `"poisson"` calls `f2_poisson()` and `f3_poisson()`.
#'   - `"gaussian"` calls `f2_gaussian()` and `f3_gaussian()`.
#' * These kernels ultimately rely on the same C math routines that R itself
#'   uses (from the `nmath`/`rmath` libraries), ensuring numerical consistency
#'   with base R functions like `dnorm`, `dpois`, etc.
#'
#' **3. GPU backend (`f2_f3_opencl`)**
#'
#' * This function mirrors the CPU backend but executes the likelihood and
#'   gradient calculations on an OpenCL device (GPU or CPU).
#' * It flattens the input matrices/vectors and allocates output buffers.
#' * It then constructs a full OpenCL program by concatenating:
#'   - a generic OpenCL support header (`OPENCL.CL`),
#'   - OpenCL ports of R's `rmath`, `nmath`, and `dpq` libraries,
#'   - and the family/link-specific kernel source (e.g.
#'     `f2_f3_binomial_logit.cl`).
#' * The resulting program is compiled and passed to a kernel runner
#'   (`f2_f3_kernel_runner`) which executes the likelihood and gradient
#'   calculations in parallel on the device.
#' * This ensures that the GPU backend produces results consistent with the
#'   CPU backend, but can scale to much larger grids efficiently.
#'
#' **4. Pilot timing (`run_opencl_pilot`)**
#'
#' * This helper runs a small subset of the grid through the OpenCL backend
#'   to estimate runtime.
#' * It is used by `Ex_EnvelopeEval()` to inform users (when `verbose = TRUE`)
#'   whether OpenCL acceleration is likely to be beneficial.
#'
#' **5. Returned values**
#'
#' * All backends return a list with:
#'   - `NegLL`: numeric vector of negative log-likelihood values.
#'   - `cbars`: numeric matrix of gradients (parameters * grid points).
#'   
#' **6. Role of likelihood and gradients in sampling**
#'
#' * The outputs of `Ex_EnvelopeEval()` - the negative log-likelihood values
#'   (`NegLL`) and the gradient matrix (`cbars`) - are not endpoints in
#'   themselves. They form the *envelope* used in the rejection sampler
#'   implemented by internal functions such as
#'   `.rNormalGLM_std_cpp()`.
#' * This routine is called by `.rNormalGLM_cpp()`, which underlies the
#'   user-facing function `rNormal_reg()`. Together they implement
#'   envelope-based posterior sampling for GLMs with log-concave likelihoods
#'   and multivariate normal priors.
#'
#' **7. Simulation execution (accept/reject procedure)**
#'
#' The acceptance test is performed using
#' \deqn{
#'   \log(U_2) \leq
#'   \log f(y \mid \theta_i) -
#'   \Big(\log f(y \mid \bar{\theta}_{J(i)}) -
#'        c(\bar{\theta}_{J(i)})^T(\theta_i - \bar{\theta}_{J(i)})\Big) \leq 0
#' }
#'
#' **Connections between code and notation:**
#' * The arguments `G4` (in `Ex_EnvelopeEval`) and `b` (in `f2_f3_*`) both
#'   represent the grid of tangency points \eqn{\bar{\theta}_j}.
#' * The output `NegLL` corresponds to
#'   \eqn{-\log f(y \mid \bar{\theta}_{J(i)})}, i.e. the negative
#'   log-likelihood evaluated at each tangency point.
#' * The output `cbars` corresponds to the subgradient vectors
#'   \eqn{c(\bar{\theta}_{J(i)})}, which define the tangent hyperplanes
#'   used in the envelope construction.
#'
#' **Precomputation for efficiency:**
#' * Both `NegLL` and `cbars` are computed once during envelope construction,
#'   prior to the simulation stage.
#' * This means the sampler does not need to recompute likelihoods or
#'   gradients at every candidate draw - it simply reuses the stored values
#'   (`NegLL`, `cbars`, and `LLconst`) in the acceptance inequality.
#'
#' This design ensures that the envelope is tangent to the log-likelihood at
#' each \eqn{\bar{\theta}_j}, lies above it elsewhere, and that the
#' accept-reject procedure can run efficiently while still producing samples
#' from the true posterior \eqn{\pi(\theta \mid y)}.
#'
#' @seealso \code{\link{Ex_EnvelopeSize}};
#' Vignettes:
#' \insertCite{glmbayesSimmethods,glmbayesChapterA08,glmbayesChapterA10,glmbayesChapter12}{nmathopencl}.
#'
#' @references
#' \insertAllCited{}
#' @return
#' \describe{
#'   \item{Ex_EnvelopeEval}{List with components \code{NegLL} (numeric vector of
#'   negative log-likelihood values) and \code{cbars} (numeric matrix of gradients).}
#'   \item{f2_f3_non_opencl}{List with components \code{qf} (negative log-likelihood)
#'   and \code{grad} (gradients) from the CPU kernel.}
#'   \item{f2_f3_opencl}{List with components \code{qf} and \code{grad} from the
#'   OpenCL kernel.}
#'   \item{run_opencl_pilot}{Numeric scalar giving estimated runtime (seconds)
#'   for OpenCL evaluation on a pilot subset of the grid.}
#' }
#'
#' @example inst/examples/Ex_EnvelopeEval.R
#'
#' @rdname Ex_EnvelopeEval
#' @export
#' @usage Ex_EnvelopeEval(G4, y, x, mu, P, alpha, wt,
#'                     family, link,
#'                     use_opencl = FALSE, verbose = FALSE)
Ex_EnvelopeEval <- function(G4, y, x, mu, P, alpha, wt,
                         family, link,
                         use_opencl = FALSE,
                         verbose = FALSE) {
  if (!is.matrix(G4)) stop("G4 must be a numeric matrix")
  if (!is.numeric(y)) stop("y must be numeric")
  if (!is.matrix(x)) stop("x must be a numeric matrix")
  if (!is.matrix(mu)) stop("mu must be a numeric matrix")
  if (!is.matrix(P)) stop("P must be a numeric matrix")
  if (!is.numeric(alpha)) stop("alpha must be numeric")
  if (!is.numeric(wt)) stop("wt must be numeric")
  if (!is.character(family) || length(family) != 1L) stop("family must be a string")
  if (!is.character(link) || length(link) != 1L) stop("link must be a string")
  
  
  .EnvelopeEval_cpp(G4, y, x, mu, P, alpha, wt,
               family, link,
               use_opencl, verbose)
}






#' @title Ex_EnvelopeOpt
#' @description Internal adaptive grid optimizer called by \code{.EnvelopeSize_cpp}.
#' @param a1 Numeric vector of diagonal data precision values.
#' @param n Integer; number of posterior draws.
#' @param core_cnt Integer; number of parallel workers (default 1).
#' @return Integer vector of grid sizes (1 or 3) per dimension.
#' @keywords internal
#' @export
Ex_EnvelopeOpt <- function(a1, n, core_cnt = 1L) {
  core_cnt <- as.integer(core_cnt)
  if (is.na(core_cnt) || core_cnt < 1L) core_cnt <- 1L
  a1rank <- rank(1 / (1 + a1))
  l1 <- length(a1)
  dimcount <- matrix(0, (l1 + 1), l1)
  scaleest <- matrix(0, (l1 + 1), l1)
  intest  <- c(1:(l1 + 1))
  slopeest <- c(1:(l1 + 1))
  dimcount[1, ] <- diag(diag(l1))
  scaleest[1, ] <- sqrt(1 + a1)
  slopeest[1]   <- prod(scaleest[1, ])
  for (i in 2:(l1 + 1)) {
    dimcount[i, ] <- dimcount[i - 1, ]
    scaleest[i, ] <- scaleest[i - 1, ]
    for (j in 1:l1) {
      if (a1rank[j] == i - 1) {
        dimcount[i, j] <- 3
        scaleest[i, j] <- 2 / sqrt(pi)
      }
    }
    intest[i]  <- 3^(i - 1)
    slopeest[i] <- prod(scaleest[i, ])
  }
  evalest  <- (intest / core_cnt) + n * slopeest
  minindex <- 0
  for (j in 1:(l1 + 1)) {
    if (evalest[j] == min(evalest)) minindex <- j
  }
  dimcount[minindex, ]
}

# Internal log-difference-of-exponentials helper used in Ex_glmbfamfunc closures
dpois2 <- function(x, lambda, log = TRUE) {
  if (log) {
    return(x * log(lambda) - lambda - lgamma(x + 1))
  } else {
    return(exp(x * log(lambda) - lambda - lgamma(x + 1)))
  }
}
