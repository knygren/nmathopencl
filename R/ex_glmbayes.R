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
#'   \item{\code{f1}}{Neg log-likelihood in coefficients \code{b} (usual data args).}
#'   \item{\code{f2}}{Neg log-posterior: likelihood plus Normal(\code{mu}, \code{P}) quadratic penalty.}
#'   \item{\code{f3}}{Gradient of \code{f2} w.r.t.\ \code{b} (argument pattern mirrors \code{f2}).}
#'   \item{\code{f4}}{Deviance gap vs saturation; honours \code{dispersion};\cr quasi / DIC helper.}
#'   \item{\code{f7}}{Weighted curvature / Hessian proxy at \code{b}.\cr}
#'   }
#'   Slots \code{f5} and \code{f6} are **not** returned: they were reserved for alternate or
#'   C++-aligned likelihood/posterior routines and remain commented out in the implementation
#'   (only \code{f1}, \code{f2}, \code{f3}, \code{f4}, and \code{f7} are assigned in the returned list).
#' @details
#'   Compiled paths dominate;\cr retain \code{Ex_glmbfamfunc} closures for scripted workflows.
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
#' @param P Positive-definite prior precision (\eqn{m \\times m}).
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
#' @details Starts from the posterior mode quantities and proceeds in three transformations.\cr
#' Step 1: posterior-precision eigendecomp.\cr Interim model gets identity posterior precision.\cr
#' Step 2: isolate diagonal \code{epsilon}; remainder behaves like likelihood information.\cr
#' Step 3: another eigendecomp diagonalizes data precision \code{A}.\cr The
#' prior tied to \code{epsilon} becomes identity.\cr
#' \insertCite{Nygren2006}{nmathopencl}
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
#' \insertCite{glmbayesSimmethods}{nmathopencl}
#' \insertCite{glmbayesChapterA08}{nmathopencl}
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
#' @details Compact overview.\cr
#' Derivations:\\cr vignettes/equations (\insertCite{Nygren2006}{nmathopencl}).\cr
#' * Dispatcher fans out to CPU and OpenCL kernel runners.\cr
#' * \verb{NegLL} vectors plus \verb{cbars} matrices feed envelopes in
#'   \code{rNormal_reg} internals.\cr
#' * Acceptance inequalities mirror the vignette ``Simulation execution'' chapter.
#'
#' @seealso \code{\link{Ex_EnvelopeSize}}
#' \insertCite{glmbayesSimmethods}{nmathopencl}
#' \insertCite{glmbayesChapterA08}{nmathopencl}
#' \insertCite{glmbayesChapterA10}{nmathopencl}
#' \insertCite{glmbayesChapter12}{nmathopencl}
#'
#' @references
#' \insertAllCited{}
#' @return
#' \describe{
#'   \item{Ex_EnvelopeEval}{\code{NegLL}: negatives logLik; \code{cbars}: tangent gradients.}
#'   \item{f2_f3_non_opencl}{\code{qf}/\code{grad} from CPU kernels.}
#'   \item{f2_f3_opencl}{\code{qf}/\code{grad} from OpenCL.}
#'   \item{run_opencl_pilot}{Pilot runtime estimate (seconds).}
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
