
//#include <Rcpp.h>
#include <vector>
#include <string>
#include "kernel_loader.h"
#include "OpenCL_helper.h"
#include "kernel_wrappers.h"
#include "kernel_runners.h"
#include <RcppArmadillo.h>
#include "famfuncs.h"
using namespace Rcpp;

using namespace OpenCLHelper;


// // forward declare the runner
// void f2_binomial_logit_prep_kernel_runner(
//     const std::string& kernel_source,
//     const char*        kernel_name,
//     int                l1,
//     int                l2,
//     int                m1,
//     const std::vector<double>& X_flat,
//     const std::vector<double>& B_flat,
//     const std::vector<double>& mu_flat,
//     const std::vector<double>& P_flat,
//     const std::vector<double>& alpha_flat,
//     std::vector<double>&       qf_flat,
//     std::vector<double>&       xb_flat,
//     int progbar
// );

// [[Rcpp::export]]
Rcpp::List f2_binomial_logit_prep_opencl(
    Rcpp::NumericMatrix b,
    Rcpp::NumericVector y,
    Rcpp::NumericMatrix x,
    Rcpp::NumericMatrix mu,
    Rcpp::NumericMatrix P,
    Rcpp::NumericVector alpha,
    Rcpp::NumericVector wt,
    int progbar 
) {
  int l1 = x.nrow(), l2 = x.ncol(), m1 = b.ncol();
  
  // prepare flat inputs
  auto X_flat     = flattenMatrix(x);
  auto B_flat     = flattenMatrix(b);
  auto mu_flat    = flattenMatrix(mu);
  auto P_flat     = flattenMatrix(P);
  auto alpha_flat = copyVector(alpha);
  

  
  // prepare outputs
  std::vector<double> qf_flat(m1);
  std::vector<double> xb_flat((size_t)l1 * m1);
  
  Rcpp::NumericVector qf(m1);
  Rcpp::NumericMatrix xb(l1, m1);
  
   
#ifdef USE_OPENCL

  
  // load kernels
  //std::string core_src = load_kernel_library("f2_binomial_logit_prep"); 
  std::string ksrc     = load_kernel_source("src/f2_binomial_logit_prep.cl");
//  std::string all_src  = core_src + "\n" + ksrc;
  std::string all_src  = ksrc;
  
  // call runner
  f2_binomial_logit_prep_kernel_runner(
    all_src,
    "f2_binomial_logit_prep",
    l1, l2, m1,
    X_flat, B_flat, mu_flat, P_flat, alpha_flat,
    qf_flat, xb_flat,
    progbar
  );
  

  
  // reconstruct R outputs
  for (int j = 0; j < m1; ++j) qf[j] = qf_flat[j];
  
  for (int j = 0; j < m1; ++j)
    for (int i = 0; i < l1; ++i)
      xb(i, j) = xb_flat[(size_t)j * l1 + i];
#else
  Rcpp::Rcout << "[INFO] OpenCL not available — returning zero vector/matrices.\n";
  
#endif 
  
  return Rcpp::List::create(
    Rcpp::Named("xb") = xb,
    Rcpp::Named("qf") = qf
  );
}



// [[Rcpp::export]]
Rcpp::List f2_binomial_logit_prep_grad_opencl(
    Rcpp::NumericMatrix  b,
    Rcpp::NumericVector  y,
    Rcpp::NumericMatrix  x,
    Rcpp::NumericMatrix  mu,
    Rcpp::NumericMatrix  P,
    Rcpp::NumericVector  alpha,
    Rcpp::NumericVector  wt,
    int                  progbar
) {
  int l1 = x.nrow(), l2 = x.ncol(), m1 = b.ncol();
  
  // flatten inputs
  auto X_flat     = flattenMatrix(x);
  auto B_flat     = flattenMatrix(b);
  auto mu_flat    = flattenMatrix(mu);
  auto P_flat     = flattenMatrix(P);
  auto alpha_flat = copyVector(alpha);
  auto y_flat     = copyVector(y);
  auto wt_flat    = copyVector(wt);
  
  // allocate outputs
  std::vector<double> qf_flat(m1);
  std::vector<double> xb_flat(static_cast<size_t>(l1) * m1);
  std::vector<double> grad_flat(static_cast<size_t>(m1) * l2);
  
  Rcpp::NumericMatrix xb(l1, m1);
  Rcpp::NumericVector qf(m1);
  
#ifdef USE_OPENCL
  
  // load & call kernel runner
  std::string ksrc    = load_kernel_source("src/f2_binomial_logit_prep.cl");
  std::string all_src = ksrc;
  
  f2_binomial_logit_prep_grad_kernel_runner(
    all_src,
    "f2_binomial_logit_prep_grad",
    l1, l2, m1,
    X_flat, B_flat, mu_flat, P_flat, alpha_flat,
    y_flat, wt_flat,
    qf_flat, xb_flat, grad_flat,
    progbar
  );
  
  // rebuild xb, qf exactly as before
  for (int j = 0; j < m1; ++j) {
    qf[j] = qf_flat[j];
    for (int i = 0; i < l1; ++i) {
      xb(i, j) = xb_flat[static_cast<size_t>(j) * l1 + i];
    }
  }
  
#else
  
  Rcpp::Rcout << "[INFO] OpenCL not available — returning zero vector/matrices.\n";
  
#endif
  
  // wrap gradient directly as arma::mat (m1 rows × l2 cols),
  // no copies, column-major data matches Armadillo & R
  arma::mat grad_arma(
      grad_flat.data(),  // pointer to your flat array
      m1,                // n_rows - dimensions
      l2,                // n_cols - grid points
      false,             // don't copy memory
      false              // strict = false
  );
  
  return Rcpp::List::create(
    Rcpp::Named("xb")   = xb,
    Rcpp::Named("qf")   = qf,
    Rcpp::Named("grad") = grad_arma
  );
}

//////////////////////////  GENERALIZATION /////////////////////





// [[Rcpp::export]]
Rcpp::List f2_prep_grad_opencl(
    std::string family,
    std::string link,
    Rcpp::NumericMatrix  b,
    Rcpp::NumericVector  y,
    Rcpp::NumericMatrix  x,
    Rcpp::NumericMatrix  mu,
    Rcpp::NumericMatrix  P,
    Rcpp::NumericVector  alpha,
    Rcpp::NumericVector  wt,
    int                  progbar
) {
  int l1 = x.nrow(), l2 = x.ncol(), m1 = b.ncol();
  
  // flatten inputs
  auto X_flat     = flattenMatrix(x);
  auto B_flat     = flattenMatrix(b);
  auto mu_flat    = flattenMatrix(mu);
  auto P_flat     = flattenMatrix(P);
  auto alpha_flat = copyVector(alpha);
  auto y_flat     = copyVector(y);
  auto wt_flat    = copyVector(wt);
  
  // allocate outputs
  std::vector<double> qf_flat(m1);
  std::vector<double> xb_flat(static_cast<size_t>(l1) * m1);
  std::vector<double> grad_flat(static_cast<size_t>(m1) * l2);
  
  Rcpp::NumericMatrix xb(l1, m1);
  Rcpp::NumericVector qf(m1);
  
  // Dispatch kernel name and source
  std::string kernel_name;
  std::string kernel_file;
  
  
#ifdef USE_OPENCL

    
  
  if (family == "binomial") {
    if (link == "logit") {
      kernel_name = "f2_binomial_logit_prep_grad";
      kernel_file = "src/f2_binomial_logit_prep.cl";
    } else if (link == "probit") {
      kernel_name = "f2_binomial_probit_prep_grad";
      kernel_file = "src/f2_binomial_probit_prep.cl";
    } else if (link == "cloglog") {
      kernel_name = "f2_binomial_cloglog_prep_grad";
      kernel_file = "src/f2_binomial_cloglog_prep.cl";
    } else {
      Rcpp::stop("Unsupported link function for binomial family: " + link);
    }
  }
  if (family =="poisson"){
    kernel_name = "f2_poisson_prep_grad";
    kernel_file  = "src/f2_poisson_prep.cl";
  }
    
  else {
    Rcpp::stop("Unsupported family: " + family);
  }

  // load & call kernel runner
  std::string ksrc    = load_kernel_source(kernel_file);
  std::string all_src = ksrc;
  
  
  
  f2_binomial_logit_prep_grad_kernel_runner(
    all_src,
    kernel_name.c_str(),  // ✅ convert to const char*
    l1, l2, m1,
    X_flat, B_flat, mu_flat, P_flat, alpha_flat,
    y_flat, wt_flat,
    qf_flat, xb_flat, grad_flat,
    progbar
  );
  
  // rebuild xb, qf exactly as before
  for (int j = 0; j < m1; ++j) {
    qf[j] = qf_flat[j];
    for (int i = 0; i < l1; ++i) {
      xb(i, j) = xb_flat[static_cast<size_t>(j) * l1 + i];
    }
  }
  
#else
  
  Rcpp::Rcout << "[INFO] OpenCL not available — returning zero vector/matrices.\n";
  
#endif
  
  // wrap gradient directly as arma::mat (m1 rows × l2 cols),
  // no copies, column-major data matches Armadillo & R
  arma::mat grad_arma(
      grad_flat.data(),  // pointer to your flat array
      m1,                // n_rows - dimensions
      l2,                // n_cols - grid points
      false,             // don't copy memory
      false              // strict = false
  );
  
  return Rcpp::List::create(
    Rcpp::Named("xb")   = xb,
    Rcpp::Named("qf")   = qf,
    Rcpp::Named("grad") = grad_arma
  );
}






// [[Rcpp::export]]
Rcpp::NumericVector f2_accum(
    std::string family,
    std::string link,
    Rcpp::NumericMatrix xb,        // n × m matrix of π = P(y=1)
    Rcpp::NumericVector qf,        // length m: 0.5*(b-μ)'P(b-μ)
    Rcpp::NumericVector y,         // length n observed {0,1}
    Rcpp::NumericVector wt,        // length n weights
    int progbar                    // 0 = no bar, 1 = show bar
) {
  int n = xb.nrow();
  int m = xb.ncol();
  Rcpp::NumericVector res(m);
  
  for (int i = 0; i < m; ++i) {
    Rcpp::checkUserInterrupt();
    
    // extract column i of xb
    Rcpp::NumericVector xbi = xb(_, i);
    
    // dispatch to appropriate likelihood function
    Rcpp::NumericVector ll;
    
    if (family == "binomial") {
      ll = dbinom_glmb(y, wt, xbi, true);
    }
    
    if (family=="poisson"){
      
      
      // if (i == 1) {
      //   const int K = std::min(n, 8);  // max rows to print
      //   Rcpp::Rcout << "\n[DEBUG] f2_accum: i = " << i << " — inputs to dpois_glmb\n";
      //   Rcpp::Rcout << std::setprecision(17);
      //   
      //   double xb_min = xb(0, i), xb_max = xb(0, i);
      //   for (int j = 1; j < n; ++j) {
      //     double val = xb(j, i);
      //     if (val < xb_min) xb_min = val;
      //     if (val > xb_max) xb_max = val;
      //   }
      //   
      //   Rcpp::Rcout << "  y.length = " << y.size()
      //               << ", xb.nrow = " << xb.nrow()
      //               << ", wt.length = " << wt.size() << "\n";
      //   Rcpp::Rcout << "  xb[:, " << i << "] range: [" << xb_min << ", " << xb_max << "]\n";
      //   
      //   Rcpp::Rcout << "  head(y, xb[,i], wt) for first " << K << " records:\n";
      //   for (int j = 0; j < K; ++j) {
      //     Rcpp::Rcout << "    j=" << j
      //                 << "  y=" << y[j]
      //                 << "  xb=" << xb(j, i)
      //                 << "  wt=" << wt[j] << "\n";
      //   }
      //   
      //   Rcpp::Rcout << "  qf[" << i << "] = " << qf[i] << "\n";
      // }  
      
      
      //ll = dbinom_glmb(y, wt, xbi, true);
      //ll=dpois_glmb(y,xb,true);
      ll=dpois_glmb(y,xbi,true);
      
      // sumxb = std::accumulate(xb.begin(), xb.end(), 0.0);
      // sumll2 = std::accumulate(ll.begin(), ll.end(), 0.0);
      
      for(int j=0;j<n;j++){
        ll[j]=ll[j]*wt[j];  
      }
      
      
    }
    
    else {
      Rcpp::stop("Unsupported family: " + family);
    }
    
    // sum of log-likelihoods
    double sumll = std::accumulate(ll.begin(), ll.end(), 0.0);
    
    // total negative log-lik = quadratic form + (− sum log-lik)
    res[i] = qf[i] - sumll;
    // 
    // if (i == 1) {
    //   Rcpp::Rcout << "  sumxb = " << std::setprecision(17) << sumxb << "\n";
    //   Rcpp::Rcout << "  sum11_raw = " << std::setprecision(17) << sumll2 << "\n";
    //   Rcpp::Rcout << "  sum11 = " << std::setprecision(17) << sumll << "\n";
    //   Rcpp::Rcout << "  res[1] = " << std::setprecision(17) << res(i) << "\n";
    // }
    
  }
  
  return res;
}