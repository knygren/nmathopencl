// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#include "RcppArmadillo.h"
#include "ex_glmbayes_simfuncs.h"

using namespace Rcpp;

namespace glmbayes {

namespace sim {

Rcpp::List glmb_Standardize_Model(
    NumericVector y, 
    NumericMatrix x,   // Original design matrix (to be adjusted)
    NumericMatrix P,   // Prior Precision Matrix (to be adjusted)
    NumericMatrix bstar, // Posterior Mode from optimization (to be adjusted)
    NumericMatrix A1  // Precision for Log-Posterior at posterior mode (to be adjusted)
  ) {
  
  int l1=x.ncol();
  int l2=x.nrow();

  arma::mat x2(x.begin(), l2, l1, false);
  arma::mat P2(P.begin(), P.nrow(), P.ncol(), false);
  arma::mat b2(bstar.begin(), bstar.nrow(), bstar.ncol(), false);
  arma::mat A1_b(A1.begin(), l1, l1, false); 
  
  NumericMatrix A4_1(l1, l1);  
  NumericMatrix b4_1(l1,1);
  NumericMatrix x4_1(l2, l1);
  NumericMatrix mu4_1(l1,1);  
  NumericMatrix P5_1(l1, l1);
  NumericMatrix P6Temp_1(l1, l1);
  NumericMatrix L2Inv_1(l1, l1); 
  NumericMatrix L3Inv_1(l1, l1); 

  double scale=1;
  int check=0;
  double eigval_temp;
  
  Rcpp::Function asVec("as.vector");

  arma::mat L2Inv(L2Inv_1.begin(), L2Inv_1.nrow(), L2Inv_1.ncol(), false);
  arma::mat L3Inv(L3Inv_1.begin(), L3Inv_1.nrow(), L3Inv_1.ncol(), false);
  arma::mat b4(b4_1.begin(), b4_1.nrow(), b4_1.ncol(), false);
  arma::mat x4(x4_1.begin(), x4_1.nrow(), x4_1.ncol(), false);
  arma::mat A4(A4_1.begin(), A4_1.nrow(), A4_1.ncol(), false);
  arma::mat P5(P5_1.begin(), P5_1.nrow(), P5_1.ncol(), false);
  arma::mat P6Temp(P6Temp_1.begin(), P6Temp_1.nrow(), P6Temp_1.ncol(), false);
  arma::vec eigval_1;
  arma::mat eigvec_1;
  arma::vec eigval_2;
  arma::mat eigvec_2;
  arma::mat ident=arma::mat (l1,l1,arma::fill::eye);
  
  eig_sym(eigval_1, eigvec_1, A1_b);
      
  double lambda_min = eigval_1.min();
  double lambda_max = eigval_1.max();
  double kappa_H    = lambda_max / lambda_min;
  
  if (!R_finite(kappa_H)) {
    Rcpp::Rcout <<
      "[glmb_Standardize_Model][WARNING] Posterior Hessian is not finite.\n"
      "  kappa(H) is NaN or Inf.\n"
      "  Standardization is likely to be numerically unstable.\n";
  }
  else if (kappa_H > 1e8) {
    Rcpp::Rcout <<
      "[glmb_Standardize_Model][WARNING] Posterior Hessian is effectively singular.\n"
      "  kappa(H) = " << kappa_H << "\n"
      "  Standardization may be unreliable; curvature is dominated by roundoff.\n";
  }
  else if (kappa_H > 1e6) {
    Rcpp::Rcout <<
      "[glmb_Standardize_Model][WARNING] Posterior Hessian is numerically dangerous.\n"
      "  kappa(H) = " << kappa_H << "\n"
      "  Curvature is extremely uneven; standardization may be unstable.\n";
  }
  else if (kappa_H > 1e5) {
    Rcpp::Rcout <<
      "[glmb_Standardize_Model][WARNING] Posterior Hessian is severely ill-conditioned.\n"
      "  kappa(H) = " << kappa_H << "\n"
      "  Expect sensitivity to rounding and potential instability.\n";
  }
  else if (kappa_H > 1e4) {
    Rcpp::Rcout <<
      "[glmb_Standardize_Model][NOTE] Posterior Hessian is moderately ill-conditioned.\n"
      "  kappa(H) = " << kappa_H << "\n";
  }
      
  arma::mat D1=arma::diagmat(eigval_1);
  arma::mat L2= arma::sqrt(D1)*trans(eigvec_1);
  L2Inv=eigvec_1*sqrt(inv_sympd(D1));

  arma::mat b3=L2*b2;   
  arma::mat x3=x2*L2Inv;
  arma::mat P3=trans(L2Inv)*P2*L2Inv;
    
  arma::mat P3Diag=arma::diagmat(arma::diagvec(P3));
  arma::mat epsilon=P3Diag;
  arma::mat P4=P3Diag;   

  while(check==0){
    epsilon=scale*P3Diag;
    P4=P3-epsilon;				
    eig_sym(eigval_2, eigvec_2, P4);
    eigval_temp=arma::min(eigval_2);
    if(eigval_temp>0){check=1;}
    else{scale=scale/2;}
  }

  arma::mat A3=ident-epsilon;

  eig_sym(eigval_2, eigvec_2, epsilon);
  arma::mat D2=arma::diagmat(eigval_2);
    
  arma::mat L3= arma::sqrt(D2)*trans(eigvec_2);
  L3Inv=eigvec_2*sqrt(inv_sympd(D2));
  b4=L3*b3; 
  x4=x3*L3Inv;
  A4=trans(L3Inv)*A3*L3Inv;
  P5=trans(L3Inv)*P4*L3Inv;
  P6Temp=P5+ident;

  NumericVector b5=asVec(b4_1);
  NumericMatrix mu5_1=0*mu4_1;

  return Rcpp::List::create(
    Rcpp::Named("bstar2")=b5,
    Rcpp::Named("A")=A4_1,
    Rcpp::Named("x2")=x4_1,
    Rcpp::Named("mu2")=mu5_1,
    Rcpp::Named("P2")=P5_1,
    Rcpp::Named("L2Inv")=L2Inv,
    Rcpp::Named("L3Inv")=L3Inv
  );
}

} // namespace sim
} // namespace glmbayes
