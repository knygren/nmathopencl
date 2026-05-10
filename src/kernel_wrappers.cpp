//#include <Rcpp.h>
#include <vector>
#include <string>
#include "openclPort.h"
#include <RcppArmadillo.h>
#include "famfuncs.h"
#include "opencl.h"

using namespace Rcpp;

using namespace openclPort;
using namespace glmbayes::opencl;

namespace glmbayes {

namespace opencl {

Rcpp::List f2_f3_opencl(
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
  
  [[maybe_unused]] int l1 = x.nrow();
  [[maybe_unused]] int l2 = x.ncol();
  int m1 = b.ncol();
  
//  int l1 = x.nrow(), l2 = x.ncol(), m1 = b.ncol();
  
  
  
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
  std::vector<double> grad_flat(static_cast<size_t>(m1) * l2);
  
  
  Rcpp::NumericVector qf(m1);
  
  
  // Dispatch kernel name and source
  std::string kernel_name;
  std::string kernel_file;
  std::string all_src;
  
  
#ifdef USE_OPENCL
  
  std::string OPENCL_source           = load_kernel_source("OPENCL.cl");
  std::string libr_shims_source       = load_kernel_library("libR_shims", "nmathopencl", false);
  std::string r_ext_types_source      = load_kernel_library("R_ext_types", "nmathopencl", false);
  std::string r_shims_source          = load_kernel_library("R_shims", "nmathopencl", false);
  std::string r_ext_runtime_source    = load_kernel_library("R_ext_runtime", "nmathopencl", false);
  std::string r_ext_internals_source  = load_kernel_library("R_ext_internals", "nmathopencl", false);
  std::string system_source           = load_kernel_library("System", "nmathopencl", false);
  std::string nmath_source            = load_kernel_library("nmath", "nmathopencl", false);
  // Old sequence retained for reference during migration:
  // std::string rmath_source = load_kernel_library("rmath","nmathopencl", false);
  // std::string dpq_source   = load_kernel_library("dpq","nmathopencl", false);
  
  
  if (family == "binomial"||family == "quasibinomial") {
    if (link == "logit") {
      kernel_name = "f2_f3_binomial_logit";
      kernel_file = "src/f2_f3_binomial_logit.cl";
    } 
    else if (link == "probit") {
      kernel_name = "f2_f3_binomial_probit";
      kernel_file = "src/f2_f3_binomial_probit.cl";
      
    }
    else if (link == "cloglog") {
      
      kernel_name = "f2_f3_binomial_cloglog";
      kernel_file = "src/f2_f3_binomial_cloglog.cl";
      
    }
    else {
      Rcpp::stop("Unsupported link function for binomial family: " + link);
    }
  }
  
  else if (family =="poisson"||family =="quasipoisson"){
    kernel_name = "f2_f3_poisson";
    kernel_file  = "src/f2_f3_poisson.cl";
    
  }
  
  else if (family=="Gamma"){
    
    kernel_name = "f2_f3_gamma";
    kernel_file  = "src/f2_f3_gamma.cl";
  }
  
  else if (family=="gaussian"){
    
    kernel_name = "f2_f3_gaussian";
    kernel_file  = "src/f2_f3_gaussian.cl";
  }
  
  else {
    Rcpp::stop("Unsupported family: " + family);
  }  
  
  
  
  // load & call kernel runner
  std::string ksrc    = load_kernel_source(kernel_file);
  
  
  /// Updated to use same "Program" logic for all models
  
  // Old program assembly sequence (kept as comment):
  // all_src = OPENCL_source +
  //   "\n" + r_shims_source +
  //   "\n" + rext_source +
  //   "\n" + system_source +
  //   "\n" + rmath_source +
  //   "\n" + dpq_source +
  //   "\n" + nmath_source +
  //   "\n" + ksrc;

  all_src = OPENCL_source +
    "\n" + libr_shims_source +
    "\n" + r_ext_types_source +
    "\n" + r_shims_source +
    "\n" + r_ext_runtime_source +
    "\n" + r_ext_internals_source +
    "\n" + system_source +
    "\n" + nmath_source +
    "\n" + ksrc;
  
  // Rcpp::Rcout << "Entering f2_f3_kernel runner \n";
  
  
  f2_f3_kernel_runner(
    all_src,
    kernel_name.c_str(),  // ✅ convert to const char*
    l1, l2, m1,
    X_flat, B_flat, mu_flat, P_flat, alpha_flat,
    y_flat, wt_flat,
    qf_flat, 
    // xb_flat,
    grad_flat,
    progbar
  );
  
  // Rcpp::Rcout << "Exiting f2_f3_kernel runner \n";
  
  
  // rebuild xb, qf exactly as before
  for (int j = 0; j < m1; ++j) {
    qf[j] = qf_flat[j];
    // for (int i = 0; i < l1; ++i) {
    //   xb(i, j) = xb_flat[static_cast<size_t>(j) * l1 + i];
    // }
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
    // Rcpp::Named("xb")   = xb,
    Rcpp::Named("qf")   = qf,
    Rcpp::Named("grad") = grad_arma
  );
}

Rcpp::NumericVector dnorm_opencl(
    const Rcpp::NumericVector& x,
    double                     mu,
    double                     sigma,
    bool                       give_log,
    bool                       verbose
) {
  Rcpp::NumericVector out(x.size());

  auto cpu_fallback = [&]() {
    for (R_xlen_t i = 0; i < x.size(); ++i) {
      out[i] = R::dnorm4(x[i], mu, sigma, give_log ? 1 : 0);
    }
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) {
      Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU dnorm fallback.\n";
    }
    cpu_fallback();
    return out;
  }

  try {
    std::vector<double> x_flat = copyVector(x);
    std::vector<double> out_flat;

    std::string OPENCL_source           = load_kernel_source("OPENCL.cl");
    std::string libr_shims_source       = load_kernel_library("libR_shims", "nmathopencl", false);
    std::string r_ext_types_source      = load_kernel_library("R_ext_types", "nmathopencl", false);
    std::string r_shims_source          = load_kernel_library("R_shims", "nmathopencl", false);
    std::string r_ext_runtime_source    = load_kernel_library("R_ext_runtime", "nmathopencl", false);
    std::string r_ext_internals_source  = load_kernel_library("R_ext_internals", "nmathopencl", false);
    std::string system_source           = load_kernel_library("System", "nmathopencl", false);
    std::string nmath_source            = load_kernel_library("nmath", "nmathopencl", false);
    std::string kernel_source  = load_kernel_source("src/dnorm_kernel.cl");

    std::string all_src = OPENCL_source +
      "\n" + libr_shims_source +
      "\n" + r_ext_types_source +
      "\n" + r_shims_source +
      "\n" + r_ext_runtime_source +
      "\n" + r_ext_internals_source +
      "\n" + system_source +
      "\n" + nmath_source +
      "\n" + kernel_source;

    dnorm_kernel_runner(
      all_src,
      "dnorm_kernel",
      x_flat,
      mu,
      sigma,
      give_log ? 1 : 0,
      out_flat
    );

    for (R_xlen_t i = 0; i < out.size(); ++i) {
      out[i] = out_flat[static_cast<size_t>(i)];
    }
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL dnorm failed; using CPU fallback.\n"
                  << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) {
    Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU dnorm fallback.\n";
  }
  cpu_fallback();
  return out;
#endif
}

Rcpp::NumericVector runif_opencl(
    int    n,
    double a,
    double b,
    bool   verbose
) {
  if (n < 0) Rcpp::stop("`n` must be >= 0.");
  Rcpp::NumericVector out(n);

  auto cpu_fallback = [&]() {
    for (int i = 0; i < n; ++i) out[i] = R::runif(a, b);
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU runif fallback.\n";
    cpu_fallback();
    return out;
  }
  try {
    std::vector<double> out_flat;
    std::string all_src =
      load_kernel_source("OPENCL.cl") +
      "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
      "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
      "\n" + load_kernel_library("System", "nmathopencl", false) +
      "\n" + load_kernel_library("nmath", "nmathopencl", false) +
      "\n" + load_kernel_source("src/runif_kernel.cl");
    runif_kernel_runner(all_src, "runif_kernel", n, a, b, out_flat);
    for (int i = 0; i < n; ++i) out[i] = out_flat[static_cast<size_t>(i)];
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL runif failed; using CPU fallback.\n" << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU runif fallback.\n";
  cpu_fallback();
  return out;
#endif
}

Rcpp::NumericVector rnorm_opencl(
    int    n,
    double mu,
    double sigma,
    bool   verbose
) {
  if (n < 0) Rcpp::stop("`n` must be >= 0.");
  Rcpp::NumericVector out(n);

  auto cpu_fallback = [&]() {
    for (int i = 0; i < n; ++i) out[i] = R::rnorm(mu, sigma);
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU rnorm fallback.\n";
    cpu_fallback();
    return out;
  }
  try {
    std::vector<double> out_flat;
    std::string all_src =
      load_kernel_source("OPENCL.cl") +
      "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
      "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
      "\n" + load_kernel_library("System", "nmathopencl", false) +
      "\n" + load_kernel_library("nmath", "nmathopencl", false) +
      "\n" + load_kernel_source("src/rnorm_kernel.cl");
    rnorm_kernel_runner(all_src, "rnorm_kernel", n, mu, sigma, out_flat);
    for (int i = 0; i < n; ++i) out[i] = out_flat[static_cast<size_t>(i)];
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL rnorm failed; using CPU fallback.\n" << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU rnorm fallback.\n";
  cpu_fallback();
  return out;
#endif
}

Rcpp::NumericVector rexp_opencl(
    int    n,
    double scale,
    bool   verbose
) {
  if (n < 0) Rcpp::stop("`n` must be >= 0.");
  Rcpp::NumericVector out(n);

  auto cpu_fallback = [&]() {
    for (int i = 0; i < n; ++i) out[i] = R::rexp(scale);
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU rexp fallback.\n";
    cpu_fallback();
    return out;
  }
  try {
    std::vector<double> out_flat;
    std::string all_src =
      load_kernel_source("OPENCL.cl") +
      "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
      "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
      "\n" + load_kernel_library("System", "nmathopencl", false) +
      "\n" + load_kernel_library("nmath", "nmathopencl", false) +
      "\n" + load_kernel_source("src/rexp_kernel.cl");
    rexp_kernel_runner(all_src, "rexp_kernel", n, scale, out_flat);
    for (int i = 0; i < n; ++i) out[i] = out_flat[static_cast<size_t>(i)];
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL rexp failed; using CPU fallback.\n" << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU rexp fallback.\n";
  cpu_fallback();
  return out;
#endif
}

Rcpp::NumericVector rwilcox_opencl(
    int    n_out,
    double m,
    double n2,
    bool   verbose
) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);

  auto cpu_fallback = [&]() {
    for (int i = 0; i < n_out; ++i) out[i] = ::Rf_rwilcox(m, n2);
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU rwilcox fallback.\n";
    cpu_fallback();
    return out;
  }
  try {
    std::vector<double> out_flat;
    std::string all_src =
      load_kernel_source("OPENCL.cl") +
      "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
      "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
      "\n" + load_kernel_library("System", "nmathopencl", false) +
      "\n" + load_kernel_library("nmath", "nmathopencl", false) +
      "\n" + load_kernel_source("src/rwilcox_kernel.cl");
    rwilcox_kernel_runner(all_src, "rwilcox_kernel", n_out, m, n2, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[static_cast<size_t>(i)];
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL rwilcox failed; using CPU fallback.\n" << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU rwilcox fallback.\n";
  cpu_fallback();
  return out;
#endif
}

Rcpp::NumericVector rbinom_opencl(
    int    n_out,
    double size,
    double prob,
    bool   verbose
) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);

  auto cpu_fallback = [&]() {
    for (int i = 0; i < n_out; ++i) out[i] = ::Rf_rbinom(size, prob);
  };

#ifdef USE_OPENCL
  if (!has_opencl()) {
    if (verbose) Rcpp::Rcout << "[INFO] OpenCL unavailable; using CPU rbinom fallback.\n";
    cpu_fallback();
    return out;
  }
  try {
    std::vector<double> out_flat;
    std::string all_src =
      load_kernel_source("OPENCL.cl") +
      "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
      "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
      "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
      "\n" + load_kernel_library("System", "nmathopencl", false) +
      "\n" + load_kernel_library("nmath", "nmathopencl", false) +
      "\n" + load_kernel_source("src/rbinom_kernel.cl");
    rbinom_kernel_runner(all_src, "rbinom_kernel", n_out, size, prob, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[static_cast<size_t>(i)];
    return out;
  } catch (const std::exception& e) {
    if (verbose) {
      Rcpp::Rcout << "[WARN] OpenCL rbinom failed; using CPU fallback.\n" << e.what() << "\n";
    }
    cpu_fallback();
    return out;
  }
#else
  if (verbose) Rcpp::Rcout << "[INFO] Package built without OpenCL; using CPU rbinom fallback.\n";
  cpu_fallback();
  return out;
#endif
}

static std::string build_rmath_program_with_kernel(const std::string& kernel_rel_path) {
  return load_kernel_source("OPENCL.cl") +
    "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
    "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
    "\n" + load_kernel_library("System", "nmathopencl", false) +
    "\n" + load_kernel_library("nmath", "nmathopencl", false) +
    "\n" + load_kernel_source(kernel_rel_path);
}

Rcpp::NumericVector r_pow_opencl(int n_out, double x, double y, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/r_pow_kernel.cl"), "r_pow_kernel", n_out, x, y, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector r_pow_di_opencl(int n_out, double x, int n_exp, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/r_pow_di_kernel.cl"), "r_pow_di_kernel", n_out, x, (double)n_exp, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector log1pmx_opencl(int n_out, double x, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/log1pmx_kernel.cl"), "log1pmx_kernel", n_out, x, 0.0, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector log1pexp_opencl(int n_out, double x, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/log1pexp_kernel.cl"), "log1pexp_kernel", n_out, x, 0.0, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector log1mexp_opencl(int n_out, double x, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/log1mexp_kernel.cl"), "log1mexp_kernel", n_out, x, 0.0, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector lgamma1p_opencl(int n_out, double x, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/lgamma1p_kernel.cl"), "lgamma1p_kernel", n_out, x, 0.0, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pow1p_opencl(int n_out, double x, double y, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/pow1p_kernel.cl"), "pow1p_kernel", n_out, x, y, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector logspace_add_opencl(int n_out, double logx, double logy, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/logspace_add_kernel.cl"), "logspace_add_kernel", n_out, logx, logy, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector logspace_sub_opencl(int n_out, double logx, double logy, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/logspace_sub_kernel.cl"), "logspace_sub_kernel", n_out, logx, logy, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector logspace_sum_opencl(int n_out, double logx, double logy, bool verbose) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    std::vector<double> out_flat;
    rmath_runtime_kernel_runner(build_rmath_program_with_kernel("src/logspace_sum_kernel.cl"), "logspace_sum_kernel", n_out, logx, logy, 0.0, out_flat);
    for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i];
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector norm_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_rng_kernel_runner(build_rmath_program_with_kernel("src/norm_rand_kernel.cl"), "norm_rand_kernel", n_out, 0.0, 1.0, 1.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector unif_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_rng_kernel_runner(build_rmath_program_with_kernel("src/unif_rand_kernel.cl"), "unif_rand_kernel", n_out, 0.0, 1.0, 1.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_unif_index_opencl(int n_out, double dn, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_rng_kernel_runner(build_rmath_program_with_kernel("src/r_unif_index_kernel.cl"), "r_unif_index_kernel", n_out, 0.0, 1.0, dn, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector exp_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_rng_kernel_runner(build_rmath_program_with_kernel("src/exp_rand_kernel.cl"), "exp_rand_kernel", n_out, 0.0, 1.0, 1.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnorm_opencl(int n_out, double x, double mu, double sigma, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/pnorm_kernel.cl"), "pnorm_kernel", n_out, x, mu, sigma, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnorm_opencl(int n_out, double p, double mu, double sigma, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/qnorm_kernel.cl"), "qnorm_kernel", n_out, p, mu, sigma, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dunif_opencl(int n_out, double x, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/dunif_kernel.cl"), "dunif_kernel", n_out, x, min, max, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector punif_opencl(int n_out, double x, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/punif_kernel.cl"), "punif_kernel", n_out, x, min, max, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qunif_opencl(int n_out, double p, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/qunif_kernel.cl"), "qunif_kernel", n_out, p, min, max, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dgamma_opencl(int n_out, double x, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/dgamma_kernel.cl"), "dgamma_kernel", n_out, x, shape, scale, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pgamma_opencl(int n_out, double x, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/pgamma_kernel.cl"), "pgamma_kernel", n_out, x, shape, scale, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qgamma_opencl(int n_out, double p, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/qgamma_kernel.cl"), "qgamma_kernel", n_out, p, shape, scale, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rgamma_opencl(int n_out, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_distribution_kernel_runner(build_rmath_program_with_kernel("src/rgamma_kernel.cl"), "rgamma_kernel", n_out, shape, scale, 0.0, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qbinom_opencl(int n_out, double p, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_discrete_kernel_runner(build_rmath_program_with_kernel("src/qbinom_kernel.cl"), "qbinom_kernel", n_out, size, prob, p, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qpois_opencl(int n_out, double p, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_discrete_kernel_runner(build_rmath_program_with_kernel("src/qpois_kernel.cl"), "qpois_kernel", n_out, 0.0, 0.0, p, lambda, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnbinom_mu_opencl(int n_out, double p, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_discrete_kernel_runner(build_rmath_program_with_kernel("src/qnbinom_mu_kernel.cl"), "qnbinom_mu_kernel", n_out, size, 0.0, p, mu, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rpois_opencl(int n_out, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_discrete_kernel_runner(build_rmath_program_with_kernel("src/rpois_kernel.cl"), "rpois_kernel", n_out, 0.0, 0.0, 0.0, lambda, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnchisq_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/pnchisq_kernel.cl"), "pnchisq_kernel", n_out, x, df, ncp, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnchisq_opencl(int n_out, double p, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/qnchisq_kernel.cl"), "qnchisq_kernel", n_out, 0.0, df, ncp, 0.0, p, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnf_opencl(int n_out, double x, double df1, double df2, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/pnf_kernel.cl"), "pnf_kernel", n_out, x, df1, ncp, df2, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnf_opencl(int n_out, double p, double df1, double df2, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/qnf_kernel.cl"), "qnf_kernel", n_out, 0.0, df1, ncp, df2, p, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnbeta_opencl(int n_out, double x, double a, double b, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/pnbeta_kernel.cl"), "pnbeta_kernel", n_out, x, a, ncp, b, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnbeta_opencl(int n_out, double p, double a, double b, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/qnbeta_kernel.cl"), "qnbeta_kernel", n_out, 0.0, a, ncp, b, p, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnt_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/pnt_kernel.cl"), "pnt_kernel", n_out, x, df, ncp, 0.0, 0.0, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnt_opencl(int n_out, double p, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rmath_noncentral_kernel_runner(build_rmath_program_with_kernel("src/qnt_kernel.cl"), "qnt_kernel", n_out, 0.0, df, ncp, 0.0, p, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_check_user_interrupt_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rext_utils_kernel_runner(build_rmath_program_with_kernel("src/r_check_user_interrupt_kernel.cl"), "r_check_user_interrupt_kernel", n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_check_stack_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; rext_utils_kernel_runner(build_rmath_program_with_kernel("src/r_check_stack_kernel.cl"), "r_check_stack_kernel", n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

}
}

