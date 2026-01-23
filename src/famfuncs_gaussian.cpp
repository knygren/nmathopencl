#include "RcppArmadillo.h"
#include <RcppParallel.h>

#include <Rcpp.h>
#include "nmath_local.h"
#include "dpq_local.h"


using namespace Rcpp;



using namespace RcppParallel;

void neg_dnorm_glmb_rmat(const RcppParallel::RVector<double>& x,         // observed values
                         const std::vector<double>& means,     // normal means
                             std::vector<double>& sds,       // standard deviations
                             std::vector<double>& res,         // output buffer
                             const int lg)                                   // log=TRUE?
{
  std::size_t n = x.length();
  
  for (std::size_t i = 0; i < n; ++i) {
    double mu    = means[i];   // mean parameter
    double sigma = sds[i];     // standard deviation
    //res[i] = -R::dnorm(x[i], mu, sigma, lg);  // R-native normal density
    res[i] = -dnorm4_local(x[i], mu, sigma, lg);  // Mathlib-native normal density
    
  }
}


// void neg_dnorm_glmb_rmat_old(const RcppParallel::RVector<double>& x,         // observed values
//                          const RcppParallel::RVector<double>& means,     // normal means
//                          const RcppParallel::RVector<double>& sds,       // standard deviations
//                          RcppParallel::RVector<double>& res,             // output buffer
//                          const int lg)                                   // log=TRUE?
// {
//   std::size_t n = x.length();
//   
//   for (std::size_t i = 0; i < n; ++i) {
//     double mu    = means[i];   // mean parameter
//     double sigma = sds[i];     // standard deviation
//     //res[i] = -R::dnorm(x[i], mu, sigma, lg);  // R-native normal density
//     res[i] = -dnorm4_local(x[i], mu, sigma, lg);  // Mathlib-native normal density
//     
//       }
// }



NumericVector dnorm_glmb( NumericVector x, NumericVector means, NumericVector sds,int lg)
{
  
  
  int n = x.size() ;
  NumericVector res(n) ;
  for( int i=0; i<n; i++) res[i] = R::dnorm( x[i], means[i], sds[i],lg ) ;

  return res ;
}



NumericVector RSS(NumericVector y, NumericMatrix x,NumericMatrix b,NumericVector alpha,NumericVector wt)
{
  // Step 1: Set up dimensions
  
  int l1 = x.nrow(), l2 = x.ncol(); // Dimensions of x matrix (dims for y,alpha, and wt needs to be consistent) 
  int m1 = b.ncol();                // Number of columns for which output is needed
  
  // Step 2: Initialize b2temp and other Rcpp and arma objects used in calculations
  
  Rcpp::NumericMatrix b2temp(l2,1);
  Rcpp::NumericMatrix restemp(1,1);
  arma::mat y2(y.begin(), l1, 1, false);
  arma::mat x2(x.begin(), l1, l2, false); 
  arma::mat alpha2(alpha.begin(), l1, 1, false); 
  
  Rcpp::NumericVector xb(l1);
  arma::colvec xb2(xb.begin(),l1,false); // Reuse memory - update both below

  NumericVector sqrt_wt=sqrt(wt);
  arma::mat sqrt_wt2(sqrt_wt.begin(), l1, 1, false); 
  
  //  NumericVector invwt=1/sqrt(wt);
  
  // Moving Loop inside the function is key for speed
  
  NumericVector yy(l1);
  NumericVector res(m1);
  arma::colvec res2(res.begin(),m1,false); // Reuse memory - update both below
  
  for(int i=0;i<m1;i++){
    
  // Grab one column at a time from b and one row at a time from res
  
    b2temp=b(Range(0,l2-1),Range(i,i));

  // Point b2 to memory for that column
  
    arma::mat b2(b2temp.begin(), l2, 1, false); 
    arma::mat restemp(res.begin()+i, 1, 1, false); 
    
  // calculate weighted residuals (element by element multiplication with weights)
  
    xb2=(y2-alpha2- x2 * b2)%sqrt_wt2;
  
  // This is where RSS should be calculated
  // Not sure if this will complain about type differences
    
    restemp=trans(xb2)*xb2;

  }
  
  return res;      

  }



NumericVector  f1_gaussian(NumericMatrix b,NumericVector y,NumericMatrix x,NumericVector alpha,NumericVector wt)
{
  
  // Get dimensions of x - Note: should match dimensions of
  //  y, b, alpha, and wt (may add error checking)
  
  // May want to add method for dealing with alpha and wt when 
  // constants instead of vectors
  
  int l1 = x.nrow(), l2 = x.ncol();
  int m1 = b.ncol();
  
  //    int lalpha=alpha.nrow();
  //    int lwt=wt.nrow();
  
  Rcpp::NumericMatrix b2temp(l2,1);
  
  arma::mat x2(x.begin(), l1, l2, false); 
  arma::mat alpha2(alpha.begin(), l1, 1, false); 
  
  Rcpp::NumericVector xb(l1);
  arma::colvec xb2(xb.begin(),l1,false); // Reuse memory - update both below
  
  
  NumericVector invwt=1/sqrt(wt);
  
  // Moving Loop inside the function is key for speed
  
  NumericVector yy(l1);
  NumericVector res(m1);
  
  
  for(int i=0;i<m1;i++){
    b2temp=b(Range(0,l2-1),Range(i,i));
    arma::mat b2(b2temp.begin(), l2, 1, false); 
    
    
    xb2=alpha2+ x2 * b2;
    
    yy=-dnorm_glmb(y,xb,invwt,true);
    
    res(i) =std::accumulate(yy.begin(), yy.end(), 0.0);
    
  }
  
  return res;      
}



NumericVector  f2_gaussian(NumericMatrix b,NumericVector y, NumericMatrix x,NumericMatrix mu,NumericMatrix P,NumericVector alpha,NumericVector wt)
{
  
  // Get dimensions of x - Note: should match dimensions of
  //  y, b, alpha, and wt (may add error checking)
  
  // May want to add method for dealing with alpha and wt when 
  // constants instead of vectors
  
  int l1 = x.nrow(), l2 = x.ncol();
  int m1 = b.ncol();
  
  //    int lalpha=alpha.nrow();
  //    int lwt=wt.nrow();
  
  Rcpp::NumericMatrix b2temp(l2,1);
  
  arma::mat x2(x.begin(), l1, l2, false); 
  arma::mat alpha2(alpha.begin(), l1, 1, false); 
  
  Rcpp::NumericVector xb(l1);
  arma::colvec xb2(xb.begin(),l1,false); // Reuse memory - update both below
  
  
  NumericVector invwt=1/sqrt(wt);
  
  // Moving Loop inside the function is key for speed
  
  NumericVector yy(l1);
  NumericVector res(m1);
  NumericMatrix bmu(l2,1);
  
  arma::mat mu2(mu.begin(), l2, 1, false); 
  arma::mat bmu2(bmu.begin(), l2, 1, false); 


  double res1=0;

  
  for(int i=0;i<m1;i++){
    b2temp=b(Range(0,l2-1),Range(i,i));
    arma::mat b2(b2temp.begin(), l2, 1, false); 
    arma::mat P2(P.begin(), l2, l2, false); 
    
    bmu2=b2-mu2;
    
    res1=0.5*arma::as_scalar(bmu2.t() * P2 *  bmu2);
    
    xb2=alpha2+ x2 * b2;
    
    yy=-dnorm_glmb(y,xb,invwt,true);
  
    res(i) =std::accumulate(yy.begin(), yy.end(), res1);
    
  }
  
  return res;      
}


// arma::vec   f2_gaussian_arma(NumericMatrix b,NumericVector y, NumericMatrix x,NumericMatrix mu,NumericMatrix P,NumericVector alpha,NumericVector wt)
// {
//   
//   // Get dimensions of x - Note: should match dimensions of
//   //  y, b, alpha, and wt (may add error checking)
//   
//   // May want to add method for dealing with alpha and wt when 
//   // constants instead of vectors
//   
//   int l1 = x.nrow(), l2 = x.ncol();
//   int m1 = b.ncol();
//   
//   //    int lalpha=alpha.nrow();
//   //    int lwt=wt.nrow();
//   
//   arma::mat b2full(b.begin(), l2, m1, false);  // Shallow view over b
//   
//   Rcpp::NumericMatrix b2temp(l2,1);
//   
//   arma::mat x2(x.begin(), l1, l2, false); 
//   arma::mat alpha2(alpha.begin(), l1, 1, false); 
//   
//   Rcpp::NumericVector xb(l1);
//   arma::colvec xb2(xb.begin(),l1,false); // Reuse memory - update both below
//   
//   
//   NumericVector invwt=1/sqrt(wt);
//   
//   // Moving Loop inside the function is key for speed
//   
//   NumericVector yy(l1);
// //  NumericVector res(m1);
//   NumericMatrix bmu(l2,1);
//   
//   arma::mat mu2(mu.begin(), l2, 1, false); 
//   arma::mat bmu2(bmu.begin(), l2, 1, false); 
//   arma::vec res2(m1);  // Owning allocation
//   
//   double res1=0;
//   
//   
//   for(int i=0;i<m1;i++){
//     b2temp=b(Range(0,l2-1),Range(i,i));
//     //arma::mat b2(b2temp.begin(), l2, 1, false); 
//     arma::mat b2(b2full.colptr(i), l2, 1, false);  // View of column i, size l2 × 1
//     
//     arma::mat P2(P.begin(), l2, l2, false); 
//     
//     bmu2=b2-mu2;
//     
//     res1=0.5*arma::as_scalar(bmu2.t() * P2 *  bmu2);
//     
//     xb2=alpha2+ x2 * b2;
//     
//     // Wrap existing R memory buffers
//     RcppParallel::RVector<double> y_view(y);
//     RcppParallel::RVector<double> xb_view(xb);
//     RcppParallel::RVector<double> invwt_view(invwt);
//     RcppParallel::RVector<double> yy_view(yy); //must be preallocated to match y.size()
//     
//     // In-place evaluation using your log-scale accurate backend
//     neg_dnorm_glmb_rmat_old(y_view,  xb_view,invwt_view, yy_view,1.0);
//     
//  
//     
//  //   yy=-dnorm_glmb(y,xb,invwt,true);
//     
// //  res(i) =std::accumulate(yy.begin(), yy.end(), res1);
//     res2(i) = std::accumulate(yy.begin(), yy.end(), res1);
//   }
//   
//   return res2;      
// }


arma::vec f2_gaussian_rmat(
    const RcppParallel::RMatrix<double>& b,
    const RcppParallel::RVector<double>& y,
    const RcppParallel::RMatrix<double>& x,
    const RcppParallel::RMatrix<double>& mu,
    const RcppParallel::RMatrix<double>& P,
    const RcppParallel::RVector<double>& alpha,
    const RcppParallel::RVector<double>& wt,
    const int progbar = 0
) {
  // Match classical dims
  std::size_t l1 = x.nrow(); // observations
  std::size_t l2 = x.ncol(); // predictors
  std::size_t m1 = b.ncol(); // number of beta columns
  
  // Armadillo views over RMatrix/RVector memory
  arma::mat b2full(const_cast<double*>(&*b.begin()),  l2, m1, false);
  arma::mat x2    (const_cast<double*>(&*x.begin()),  l1, l2, false);
  arma::mat mu2   (const_cast<double*>(&*mu.begin()), l2, 1,  false);
  arma::mat P2    (const_cast<double*>(&*P.begin()),  l2, l2, false);
  arma::mat alpha2(const_cast<double*>(&*alpha.begin()), l1, 1, false);
  
  arma::vec res(m1, arma::fill::none);
  
  // invwt = 1/sqrt(wt) (length l1), identical to classical
  std::vector<double> invwt(l1);
  for (std::size_t i = 0; i < l1; ++i) {
    invwt[i] = 1.0 / std::sqrt(wt[i]);
  }
  
  // Temporary buffers (length l1)
  std::vector<double> xb_temp(l1), yy_temp(l1);
  arma::colvec xb_temp2(xb_temp.data(), l1, false); // shallow Armadillo view
  
  // Optional: one bmu buffer reused per column
  arma::mat bmu(l2, 1, arma::fill::none);
  
  for (std::size_t i = 0; i < m1; ++i) {
    // Current beta column (size l2×1)
    arma::mat b_i(b2full.colptr(i), l2, 1, false);
    
    // Prior quadratic term: 0.5*(b - mu)^T P (b - mu)
    bmu = b_i - mu2;
    double mahal = 0.5 * arma::as_scalar(bmu.t() * P2 * bmu);
    
    // FIX: Gaussian xb is alpha + x*b (no exp)
    xb_temp2 = alpha2 + x2 * b_i;
    
    // FIX: Do NOT divide xb by wt; use invwt as in classical
    // xb_temp[j] = xb_temp[j] / wt[j];  // REMOVED
    
    // Evaluate negative log-likelihood per observation (same as classical backend)
    neg_dnorm_glmb_rmat(y, xb_temp, invwt, yy_temp, 1.0);
    
    // Sum yy and add prior quadratic
    res(i) = std::accumulate(yy_temp.begin(), yy_temp.end(), mahal);
  }
  
  return res;
}


// Parallel-safe variant: wt passed as RMatrix (l1 × 1)
arma::vec f2_gaussian_rmat_mat(
    const RcppParallel::RMatrix<double>& b,
    const RcppParallel::RVector<double>& y,
    const RcppParallel::RMatrix<double>& x,
    const RcppParallel::RMatrix<double>& mu,
    const RcppParallel::RMatrix<double>& P,
    const RcppParallel::RVector<double>& alpha,
    const RcppParallel::RMatrix<double>& wt,   // l1 × 1
    const int progbar = 0
) {
  // Dimensions
  const std::size_t l1 = x.nrow(); // observations
  const std::size_t l2 = x.ncol(); // predictors
  const std::size_t m1 = b.ncol(); // number of beta columns
  
  // Armadillo views over contiguous memory (no copies)
  arma::mat b2full(const_cast<double*>(&*b.begin()),  l2, m1, false);
  arma::mat x2    (const_cast<double*>(&*x.begin()),  l1, l2, false);
  arma::mat mu2   (const_cast<double*>(&*mu.begin()), l2, 1,  false);
  arma::mat P2    (const_cast<double*>(&*P.begin()),  l2, l2, false);
  arma::mat alpha2(const_cast<double*>(&*alpha.begin()), l1, 1, false);
  
  // Wrap wt (l1 × 1) as a column vector
  arma::colvec wt2(const_cast<double*>(&*wt.begin()), l1, false);
  
  arma::vec res(m1, arma::fill::none);
  
  // invwt = 1/sqrt(wt) (length l1), identical to classical
  std::vector<double> invwt(l1);
  for (std::size_t i = 0; i < l1; ++i) {
    invwt[i] = 1.0 / std::sqrt(wt2(i));
  }
  
  // Temporary buffers (length l1), shallow view into xb_temp
  std::vector<double> xb_temp(l1), yy_temp(l1);
  arma::colvec xb_temp2(xb_temp.data(), l1, false);
  
  // Reused buffer
  arma::mat bmu(l2, 1, arma::fill::none);
  
  for (std::size_t i = 0; i < m1; ++i) {
    // Current beta column (size l2×1)
    arma::mat b_i(b2full.colptr(i), l2, 1, false);
    
    // Prior quadratic term: 0.5*(b - mu)^T P (b - mu)
    bmu = b_i - mu2;
    const double mahal = 0.5 * arma::as_scalar(bmu.t() * P2 * bmu);
    
    // Linear predictor: xb = alpha + x*b
    xb_temp2 = alpha2 + x2 * b_i;
    
    // Per-observation negative log-likelihood
    neg_dnorm_glmb_rmat(y, xb_temp, invwt, yy_temp, 1.0);
    
    // Sum yy and add prior quadratic
    res(i) = std::accumulate(yy_temp.begin(), yy_temp.end(), mahal);
  }
  
  return res;
}

arma::mat  f3_gaussian(NumericMatrix b,NumericVector y, NumericMatrix x,NumericMatrix mu,NumericMatrix P,NumericVector alpha,NumericVector wt)
{
  
  // Get dimensions of x - Note: should match dimensions of
  //  y, b, alpha, and wt (may add error checking)
  
  // May want to add method for dealing with alpha and wt when 
  // constants instead of vectors
  
  int l1 = x.nrow(), l2 = x.ncol();
  int m1 = b.ncol();
  
  //    int lalpha=alpha.nrow();
  //    int lwt=wt.nrow();
  
  Rcpp::NumericMatrix b2temp(l2,1);
  
  arma::mat y2(y.begin(), l1, 1, false);
  arma::mat x2(x.begin(), l1, l2, false); 
  arma::mat alpha2(alpha.begin(), l1, 1, false); 
  
  Rcpp::NumericVector xb(l1);
  arma::colvec xb2(xb.begin(),l1,false); // Reuse memory - update both below
  
  
  
  NumericMatrix Ptemp(l1,l1);  
  
  for(int i=0;i<l1;i++){
    Ptemp(i,i)=wt(i); 
  }  
  
  // Moving Loop inside the function is key for speed
  
  NumericVector yy(l1);
  NumericVector res(m1);
  NumericMatrix bmu(l2,1);
  NumericMatrix out(l2,m1);
  
  
  arma::mat mu2(mu.begin(), l2, 1, false); 
  arma::mat bmu2(bmu.begin(), l2, 1, false); 
  arma::mat P2(P.begin(), l2, l2, false); 
  arma::mat Ptemp2(Ptemp.begin(), l1, l1, false);
  arma::mat out2(out.begin(), l2, m1, false);
  
  NumericMatrix::Column outtemp=out(_,0);
  //NumericMatrix::Row outtempb=out(0,_);
  
  arma::mat outtemp2(outtemp.begin(),1,l2,false);
  //arma::mat outtempb2(outtempb.begin(),1,l2,false);
  
  for(int i=0;i<m1;i++){
    b2temp=b(Range(0,l2-1),Range(i,i));
    arma::mat b2(b2temp.begin(), l2, 1, false); 
    
    NumericMatrix::Column outtemp=out(_,i);
    arma::mat outtemp2(outtemp.begin(),1,l2,false);
    
    bmu2=b2-mu2;
    xb2=alpha2+ x2 * b2-y2;
    outtemp2= P2 * bmu2+x2.t() * Ptemp2 * xb2;
  }
  
  // return  b;
  
  return trans(out2);      
}



// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
using namespace Rcpp;


arma::mat Inv_f3_with_disp(Rcpp::List cache,
                           double dispersion,
                           Rcpp::NumericMatrix cbars_small) {
  arma::mat Pmat    = cache["Pmat"];
  arma::mat Pmu     = cache["Pmu"];
  arma::vec base_B0 = cache["base_B0"];
  arma::mat base_A  = cache["base_A"];
  
  // Scale the base terms
  arma::vec B0 = base_B0 / dispersion + Pmu;
  arma::mat A  = Pmat + base_A / dispersion;
  A = 0.5 * (A + A.t());
  
  arma::mat R = arma::chol(A);
  
  // Wrap cbars_small into an Armadillo view
  arma::mat Csmall(cbars_small.begin(), Pmat.n_rows, cbars_small.ncol(), false);
  
  // Use Armadillo's n_cols
  arma::mat Out(Pmat.n_rows, Csmall.n_cols);
  
  for (arma::uword i = 0; i < Csmall.n_cols; i++) {
    arma::vec cbars_i(Csmall.colptr(i), Pmat.n_rows, false);
    arma::vec b = -cbars_i + B0;
    
    arma::vec ytmp = arma::solve(arma::trimatl(R.t()), b);
    arma::vec sol  = arma::solve(arma::trimatu(R), ytmp);
    
    Out.col(i) = -sol;
  }
  
  return Out.t(); // m × p
}




// Internal: rmat-in/rmat-out, uses Armadillo for chol/solve inside.
// RcppParallel::RMatrix<double> Inv_f3_with_disp_rmat(
//     const RcppParallel::RMatrix<double>& Pmat_r,
//     const RcppParallel::RMatrix<double>& Pmu_r,
//     const RcppParallel::RVector<double>& base_B0_r,
//     const RcppParallel::RMatrix<double>& base_A_r,
//     double dispersion,
//     const RcppParallel::RMatrix<double>& cbars_r // p × m
// ) {
//   const int p = Pmat_r.nrow();
//   const int m = cbars_r.ncol();
//   
//   arma::vec B0(p);
//   for (int i = 0; i < p; ++i) {
//     B0[i] = base_B0_r[i] / dispersion + Pmu_r(i, 0);
//   }
//   
//   arma::mat A(p, p);
//   for (int r = 0; r < p; ++r) {
//     for (int c = 0; c < p; ++c) {
//       double val = Pmat_r(r, c) + base_A_r(r, c) / dispersion;
//       double sym = 0.5 * (val + (Pmat_r(c, r) + base_A_r(c, r) / dispersion));
//       A(r, c) = sym;
//     }
//   }
//   
//   arma::mat R = arma::chol(A);
//   
//   Rcpp::NumericMatrix Out_nm(m, p);
//   RcppParallel::RMatrix<double> Out_r(Out_nm);
//   
//   for (int j = 0; j < m; ++j) {
//     arma::vec cbars_i(p);
//     for (int r = 0; r < p; ++r) cbars_i[r] = cbars_r(r, j);
//     
//     arma::vec b = -cbars_i + B0;
//     arma::vec ytmp = arma::solve(arma::trimatl(R.t()), b);
//     arma::vec sol  = arma::solve(arma::trimatu(R), ytmp);
//     
//     for (int r = 0; r < p; ++r) Out_r(j, r) = -sol[r];
//   }
//   
//   return Out_r;
// }



arma::mat Inv_f3_with_disp_rmat_v2(
    const RcppParallel::RMatrix<double>& Pmat_r,
    const RcppParallel::RMatrix<double>& Pmu_r,
    const RcppParallel::RVector<double>& base_B0_r,
    const RcppParallel::RMatrix<double>& base_A_r,
    double dispersion,
    const RcppParallel::RMatrix<double>& cbars_r // p × m
) {
  const int p = Pmat_r.nrow();
  const int m = cbars_r.ncol();
  
  // Build Armadillo views over the RcppParallel memory
  arma::mat Pmat(const_cast<double*>(Pmat_r.begin()), p, p, false, true);
  arma::mat Pmu(const_cast<double*>(Pmu_r.begin()), p, 1, false, true);
  arma::mat base_A(const_cast<double*>(base_A_r.begin()), p, p, false, true);
  
  // Scale base terms
  arma::vec B0(p);
  for (int i = 0; i < p; ++i) {
    B0[i] = base_B0_r[i] / dispersion + Pmu(i, 0);
  }
  
  // Symmetrize and factor
  arma::mat A = Pmat + base_A / dispersion;
  A = 0.5 * (A + A.t());
  arma::mat R = arma::chol(A);
  
  // Output: m × p
  arma::mat Out(m, p, arma::fill::none);
  
  for (int j = 0; j < m; ++j) {
    arma::vec cbars_j(p);
    for (int r = 0; r < p; ++r) cbars_j[r] = cbars_r(r, j);
    
    arma::vec b    = -cbars_j + B0;
    arma::vec ytmp = arma::solve(arma::trimatl(R.t()), b);
    arma::vec sol  = arma::solve(arma::trimatu(R),     ytmp);
    
    Out.row(j) = (-sol).t();
  }
  
  return Out; // m × p
}