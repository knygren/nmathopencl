// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

// we only include RcppArmadillo.h which pulls Rcpp.h in for us
#include "RcppArmadillo.h"

// via the depends attribute we tell Rcpp to create hooks for
// RcppArmadillo so that the build process will know what to do
//
// [[Rcpp::depends(RcppArmadillo)]]

#include "famfuncs.h"

using namespace Rcpp;



void setlogP_C2(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3,NumericMatrix LLconst){
  
  int n = logP.nrow(), k = logP.ncol();
  int l1 =cbars.ncol();
  
  arma::mat logP2(logP.begin(), n, k, false); 
  NumericVector cbartemp=cbars(0,_);  
  NumericVector G3temp=G3(0,_);  
  
  arma::colvec cbarrow(cbartemp.begin(),l1,false);
  arma::colvec G3row(G3temp.begin(),l1,false);
  
  
  for(int i=0;i<n;i++){
    cbartemp=cbars(i,_);  
    G3temp=G3(i,_);  
    
    logP(i,1)=logP(i,0)-NegLL(i)+0.5*arma::as_scalar(cbarrow.t() * cbarrow)+arma::as_scalar(G3row.t() * cbarrow);
    
    LLconst(i,0)=NegLL(i)-arma::as_scalar(G3row.t() * cbarrow);
  }
  
  // double mn   = Rcpp::min(NegLL);
  // double mx   = Rcpp::max(NegLL);
  // double mean = Rcpp::mean(NegLL);
  // 
  // Rcpp::Rcout << "NegLL summary: min=" << mn
  //             << " mean=" << mean
  //             << " max=" << mx << "\n";
  
  // after filling logP(:,1) in the loop
  // Rcpp::NumericVector lp1 = logP(_, 1);
  

  // find indices of min and max
  // int idx_min = Rcpp::which_min(lp1);
  // int idx_max = Rcpp::which_max(lp1);
  // 
  // // values
  // double val_min = lp1[idx_min];
  // double val_max = lp1[idx_max];
  // double val_mean = Rcpp::mean(lp1);
  // 
  // print summary
  // Rcpp::Rcout << "logP(.,1) summary: min=" << val_min
  //             << " (row " << idx_min << ")"
  //             << " mean=" << val_mean
  //             << " max=" << val_max
  //             << " (row " << idx_max << ")"
  //             << std::endl;
  
  
  // After filling logP(:,1)
//  Rcpp::NumericVector lp1 = logP(_, 1);
//  int idx_max = Rcpp::which_max(lp1);  // 0-based index
  
  // Print a window of rows around the max
  // int start = std::max(0, idx_max - 2);
  // int end   = std::min(n-1, idx_max + 2);
  // 
  // Rcpp::Rcout << "Inspecting rows " << (start+1) << " to " << (end+1)
  //             << " (max at row " << (idx_max+1) << "):\n";
  
  // for (int i = start; i <= end; i++) {
  //   Rcpp::NumericVector cbart = cbars(i, _);
  //   Rcpp::NumericVector G3t   = G3(i, _);
  //   
  //   arma::colvec cbarrow(cbart.begin(), cbars.ncol(), false);
  //   arma::colvec G3row(G3t.begin(),   G3.ncol(),     false);
  //   
  //   double quad = 0.5 * arma::as_scalar(cbarrow.t() * cbarrow);
  //   double lin  = arma::as_scalar(G3row.t() * cbarrow);
  //   
  //   double rhs = logP(i,0) - NegLL[i] + quad + lin;
  //   
  //   Rcpp::Rcout << "Row " << (i+1)
  //               << " lp0=" << logP(i,0)
  //               << " NegLL=" << NegLL[i]
  //               << " quad=" << quad
  //               << " lin="  << lin
  //               << " | lp1=" << logP(i,1)
  //               << " rhs="  << rhs
  //               << " diff=" << (logP(i,1) - rhs)
  //               << "\n";
  // }
    
}


// [[Rcpp::export(".setlogP_cpp")]]


Rcpp::List   setlogP(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3) {
  
  int n = logP.nrow(), k = logP.ncol();
  int l1 =cbars.ncol();
  //    int l2=cbars.nrow();
  
  arma::mat logP2(logP.begin(), n, k, false); 
  NumericVector cbartemp=cbars(0,_);  
  NumericVector G3temp=G3(0,_);  
  Rcpp::NumericMatrix LLconst(n,1);
  
  arma::colvec cbarrow(cbartemp.begin(),l1,false);
  arma::colvec G3row(G3temp.begin(),l1,false);
  
  //    double v = arma::as_scalar(cbarrow.t() * cbarrow);
  //    LLconst[j]<--t(as.matrix(cbars[j,1:l1]))%*%t(as.matrix(G3[j,1:l1]))+NegLL[j]    
  
  for(int i=0;i<n;i++){
    cbartemp=cbars(i,_);  
    G3temp=G3(i,_);  
    logP(i,1)=logP(i,0)-NegLL(i)+0.5*arma::as_scalar(cbarrow.t() * cbarrow)+arma::as_scalar(G3row.t() * cbarrow);
    LLconst(i,0)=NegLL(i)-arma::as_scalar(G3row.t() * cbarrow);
  }
  
  
  //    return logP;
  return Rcpp::List::create(Rcpp::Named("logP")=logP,Rcpp::Named("LLconst")=LLconst);
  
}




//////////////////////////////////////////////////////////////////////////////

// Rcpp::List   setlogP_C(NumericMatrix logP,NumericVector NegLL,NumericMatrix cbars,NumericMatrix G3,NumericMatrix LLconst) {
//   
//   int n = logP.nrow(), k = logP.ncol();
//   int l1 =cbars.ncol();
//   
//   arma::mat logP2(logP.begin(), n, k, false); 
//   NumericVector cbartemp=cbars(0,_);  
//   NumericVector G3temp=G3(0,_);  
//   
//   arma::colvec cbarrow(cbartemp.begin(),l1,false);
//   arma::colvec G3row(G3temp.begin(),l1,false);
//   
//   
//   for(int i=0;i<n;i++){
//     cbartemp=cbars(i,_);  
//     G3temp=G3(i,_);  
// 
//     // Remark 6 in Nygren and Nygren (2006)
//     // logP is log_density for component
//     // -NegLL (is g())
//     // last term is log of denominator 
//     // 3rd term is MGF from Claim1
//     
//     logP(i,1)=logP(i,0)-NegLL(i)+0.5*arma::as_scalar(cbarrow.t() * cbarrow)+arma::as_scalar(G3row.t() * cbarrow);
//     
//     LLconst(i,0)=NegLL(i)-arma::as_scalar(G3row.t() * cbarrow);
//   }
//   
//   
//   return Rcpp::List::create(Rcpp::Named("logP")=logP,Rcpp::Named("LLconst")=LLconst);
//   
// }



