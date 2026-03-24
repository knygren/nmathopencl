// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#include "RcppArmadillo.h"

// #include "famfuncs.h"  // was for parity with rNormalReg.cpp (MC path commented out)
#include "Envelopefuncs.h"
#include <math.h>
// #include "simfuncs.h"  // rNormalReg (MC path) commented out below
// #include "progress_utils.h"  // only used by commented verbose timestamps below

using namespace Rcpp;
// using namespace glmbayes::sim;
// using namespace glmbayes::progress;

namespace {

/// Closed-form E[ sum_i w_i (y_i - x_i' beta - offset_i)^2 ] under the same
/// Gaussian posterior as glmbayes::sim::rNormalReg. Signature mirrors rNormalReg;
/// unused parameters keep call-site parity with rNormalReg.
double RSS_helper(
    int n,
    NumericVector y,
    NumericMatrix x,
    NumericVector mu,
    NumericMatrix P,
    NumericVector offset,
    NumericVector wt,
    double dispersion,
    Function f2,
    Function f3,
    NumericVector start,
    std::string family,
    std::string link,
    int Gridtype
) {
  (void)n;
  (void)f2;
  (void)f3;
  (void)start;
  (void)family;
  (void)link;
  (void)Gridtype;

  Function asMat("as.matrix");
  const int l1 = x.ncol();
  const int l2 = x.nrow();

  NumericMatrix mu2a = asMat(mu);
  NumericMatrix x2b = clone(x);
  arma::mat x2bb(x2b.begin(), l2, l1, false);
  arma::mat P2(P.begin(), P.nrow(), P.ncol(), false);

  NumericVector wt2 = wt / dispersion;
  NumericVector y1 = y - offset;
  arma::vec y2b(y1.begin(), l2, false);
  NumericMatrix W1(l2 + l1, l1);
  arma::mat W(W1.begin(), W1.nrow(), W1.ncol(), false);
  NumericVector z1(l2 + l1);
  arma::vec z(z1.begin(), l2 + l1, false);

  int i;
  for (i = 0; i < l2; i++) {
    x2b(i, _) = x2b(i, _) * sqrt(wt2[i]);
    y1(i) = y1(i) * sqrt(wt2[i]);
  }

  arma::mat RA = arma::chol(P2);
  W.rows(0, l2 - 1) = x2bb;
  W.rows(l2, l2 + l1 - 1) = RA;
  arma::mat mu2(mu2a.begin(), mu2a.nrow(), mu2a.ncol(), false);
  z.rows(0, l2 - 1) = y2b;
  z.rows(l2, l1 + l2 - 1) = RA * mu2;

  Function lm_fit_fun("lm.fit");
  List fit = lm_fit_fun(_["x"] = W, _["y"] = z);
  NumericMatrix b2a = asMat(fit[0]);

  arma::mat IR = arma::inv(arma::trimatu(arma::chol(arma::trans(W) * W)));
  arma::mat Sigma = IR * arma::trans(IR);
  arma::vec b2(b2a.begin(), static_cast<arma::uword>(b2a.nrow() * b2a.ncol()));

  arma::mat X = as<arma::mat>(x);
  arma::vec Y = as<arma::vec>(y);
  arma::vec off = as<arma::vec>(offset);
  arma::vec wv = as<arma::vec>(wt);

  const arma::vec r = Y - X * b2 - off;
  const double rss_at_mean = arma::dot(wv, r % r);
  const arma::mat XtWX = arma::trans(X) * (arma::diagmat(wv) * X);
  const double trace_term = arma::trace(XtWX * Sigma);
  return rss_at_mean + trace_term;
}

}  // namespace

namespace glmbayes {

namespace env {

List EnvelopeCentering(
    NumericVector y,
    NumericMatrix x,
    NumericVector mu,
    NumericMatrix P,
    NumericVector offset,
    NumericVector wt,
    double shape,
    double rate,
    int Gridtype,
    bool verbose
) {
  (void)verbose;  // retained in API; verbose logging commented out below
  // const int n_beta_draws = 10000;  // was: MC draw count; RSS_helper ignores n (see (void)n)
  const int n_rss_iter = 10;
  Rcpp::Function lm_wfit("lm.wfit");
  Rcpp::Function gaussian("gaussian");
  Rcpp::Environment glmbayes_ns = Rcpp::Environment::namespace_env("glmbayes");
  Rcpp::Function glmbfamfunc = glmbayes_ns["glmbfamfunc"];

  int n_obs = y.size();
  NumericVector ystar(n_obs);
  for (int i = 0; i < n_obs; i++) {
    ystar[i] = y[i] - offset[i];
  }

  double n_w = 0.0;
  for (int i = 0; i < wt.size(); ++i) n_w += wt[i];

  Rcpp::List fit = lm_wfit(
    Rcpp::_["x"] = x,
    Rcpp::_["y"] = ystar,
    Rcpp::_["w"] = wt
  );

  NumericVector res = fit["residuals"];
  double RSS = 0.0;
  for (int i = 0; i < res.size(); i++) {
    RSS += res[i] * res[i];
  }
  int p = Rcpp::as<int>(fit["rank"]);
  double dispersion2 = RSS / (n_obs - p);

  Rcpp::List famfunc = glmbfamfunc(gaussian());
  Rcpp::Function f2 = famfunc["f2"];
  Rcpp::Function f3 = famfunc["f3"];

  // MC path only (weighted RSS from rNormalReg draws):
  // arma::mat X = Rcpp::as<arma::mat>(x);
  // arma::vec Y = Rcpp::as<arma::vec>(y);
  // arma::rowvec y_row = Y.t();
  // arma::rowvec off_row = Rcpp::as<arma::rowvec>(offset);
  // arma::rowvec wt_row = Rcpp::as<arma::rowvec>(wt);

  // Rcpp::List cpp_out;
  double RSS_post_expected = NA_REAL;
  // double RSS_mc = NA_REAL;

  // if (verbose) {
  //   Rcpp::Rcout << "[EnvelopeCentering] Entering loop: "
  //               << glmbayes::progress::timestamp_cpp() << "\n";
  // }

  for (int j = 0; j < n_rss_iter; ++j) {
    const double RSS_closed = RSS_helper(
        0,  // n_beta_draws when MC enabled
        y, x, mu, P, offset, wt,
        dispersion2,
        f2, f3,
        mu,
        "gaussian",
        "identity",
        Gridtype
    );

    // cpp_out = rNormalReg(
    //   n_beta_draws,
    //   y, x, mu, P, offset, wt,
    //   dispersion2,
    //   f2, f3,
    //   mu,
    //   "gaussian",
    //   "identity",
    //   Gridtype
    // );

    // arma::mat beta_draws = Rcpp::as<arma::mat>(cpp_out["coefficients"]);
    // arma::mat lp_mat = beta_draws * X.t();
    // arma::mat eta_mat = lp_mat.each_row() + off_row;
    // arma::mat mu_mat = eta_mat;
    // arma::mat diff = mu_mat.each_row() - y_row;
    // arma::mat res_sq = diff % diff;
    // arma::mat res_sq_weighted = res_sq;
    // res_sq_weighted.each_row() %= wt_row;
    // arma::vec RSS_temp = arma::sum(res_sq_weighted, 1);
    // RSS_mc = arma::mean(RSS_temp);
    RSS_post_expected = RSS_closed;

    // if (verbose) {
    //   Rcpp::Rcout << "[EnvelopeCentering] iter " << j
    //               << "  RSS E[.] (closed)=" << RSS_closed
    //               << "  RSS (MC mean)=" << RSS_mc << "\n";
    // }

    double shape2 = shape + n_w / 2.0;
    double rate2 = rate + RSS_closed / 2.0;
    dispersion2 = rate2 / (shape2 - 1.0);
  }

  // if (verbose) {
  //   Rcpp::Rcout << "[EnvelopeCentering] Exiting loop: "
  //               << glmbayes::progress::timestamp_cpp() << "\n";
  // }

  return List::create(
    Named("dispersion") = dispersion2,
    Named("RSS_post") = RSS_post_expected
  );
}

}  // namespace env

}  // namespace glmbayes
