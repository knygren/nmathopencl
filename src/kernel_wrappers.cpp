//#include <Rcpp.h>
#include <vector>
#include <string>
#include "openclPort.h"
#include <RcppArmadillo.h>
#include "nmathopencl.h"

using namespace Rcpp;

using namespace openclPort;

namespace nmathopencl {


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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/r_pow_kernel.cl"), "r_pow_kernel", {x, y, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/r_pow_di_kernel.cl"), "r_pow_di_kernel", {x, (double)n_exp, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/log1pmx_kernel.cl"), "log1pmx_kernel", {x, 0.0, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/log1pexp_kernel.cl"), "log1pexp_kernel", {x, 0.0, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/log1mexp_kernel.cl"), "log1mexp_kernel", {x, 0.0, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/lgamma1p_kernel.cl"), "lgamma1p_kernel", {x, 0.0, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pow1p_kernel.cl"), "pow1p_kernel", {x, y, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/logspace_add_kernel.cl"), "logspace_add_kernel", {logx, logy, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/logspace_sub_kernel.cl"), "logspace_sub_kernel", {logx, logy, 0.0}, n_out, out_flat);
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
    opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/logspace_sum_kernel.cl"), "logspace_sum_kernel", {logx, logy, 0.0}, n_out, out_flat);
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
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/norm_rand_kernel.cl"), "norm_rand_kernel", {0.0, 1.0, 1.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector unif_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/unif_rand_kernel.cl"), "unif_rand_kernel", {0.0, 1.0, 1.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_unif_index_opencl(int n_out, double dn, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/r_unif_index_kernel.cl"), "r_unif_index_kernel", {0.0, 1.0, dn}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector exp_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/exp_rand_kernel.cl"), "exp_rand_kernel", {0.0, 1.0, 1.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnorm_opencl(int n_out, double x, double mu, double sigma, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnorm_kernel.cl"), "pnorm_kernel", {x, mu, sigma, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnorm_opencl(int n_out, double p, double mu, double sigma, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnorm_kernel.cl"), "qnorm_kernel", {p, mu, sigma, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dunif_opencl(int n_out, double x, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dunif_kernel.cl"), "dunif_kernel", {x, min, max, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector punif_opencl(int n_out, double x, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/punif_kernel.cl"), "punif_kernel", {x, min, max, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qunif_opencl(int n_out, double p, double min, double max, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qunif_kernel.cl"), "qunif_kernel", {p, min, max, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dgamma_opencl(int n_out, double x, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dgamma_kernel.cl"), "dgamma_kernel", {x, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pgamma_opencl(int n_out, double x, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pgamma_kernel.cl"), "pgamma_kernel", {x, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qgamma_opencl(int n_out, double p, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qgamma_kernel.cl"), "qgamma_kernel", {p, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rgamma_opencl(int n_out, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rgamma_kernel.cl"), "rgamma_kernel", {shape, scale, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dbeta_opencl(int n_out, double x, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dbeta_kernel.cl"), "dbeta_kernel", {x, a, b, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pbeta_opencl(int n_out, double x, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pbeta_kernel.cl"), "pbeta_kernel", {x, a, b, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qbeta_opencl(int n_out, double p, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qbeta_kernel.cl"), "qbeta_kernel", {p, a, b, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rbeta_opencl(int n_out, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rbeta_kernel.cl"), "rbeta_kernel", {a, b, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dlnorm_opencl(int n_out, double x, double meanlog, double sdlog, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dlnorm_kernel.cl"), "dlnorm_kernel", {x, meanlog, sdlog, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector plnorm_opencl(int n_out, double q, double meanlog, double sdlog, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/plnorm_kernel.cl"), "plnorm_kernel", {q, meanlog, sdlog, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qlnorm_opencl(int n_out, double p, double meanlog, double sdlog, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qlnorm_kernel.cl"), "qlnorm_kernel", {p, meanlog, sdlog, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rlnorm_opencl(int n_out, double meanlog, double sdlog, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rlnorm_kernel.cl"), "rlnorm_kernel", {meanlog, sdlog, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dchisq_opencl(int n_out, double x, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dchisq_kernel.cl"), "dchisq_kernel", {x, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pchisq_opencl(int n_out, double x, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pchisq_kernel.cl"), "pchisq_kernel", {x, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qchisq_opencl(int n_out, double p, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qchisq_kernel.cl"), "qchisq_kernel", {p, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rchisq_opencl(int n_out, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rchisq_kernel.cl"), "rchisq_kernel", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnchisq_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnchisq_kernel.cl"), "dnchisq_kernel", {x, df, ncp, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rnchisq_opencl(int n_out, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rnchisq_kernel.cl"), "rnchisq_kernel", {df, ncp, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector df_opencl(int n_out, double x, double df1, double df2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/df_kernel.cl"), "df_kernel", {x, df1, df2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pf_opencl(int n_out, double x, double df1, double df2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pf_kernel.cl"), "pf_kernel", {x, df1, df2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qf_opencl(int n_out, double p, double df1, double df2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qf_kernel.cl"), "qf_kernel", {p, df1, df2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rf_opencl(int n_out, double df1, double df2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rf_kernel.cl"), "rf_kernel", {df1, df2, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dt_opencl(int n_out, double x, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dt_kernel.cl"), "dt_kernel", {x, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pt_opencl(int n_out, double x, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pt_kernel.cl"), "pt_kernel", {x, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qt_opencl(int n_out, double p, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qt_kernel.cl"), "qt_kernel", {p, df, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rt_opencl(int n_out, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rt_kernel.cl"), "rt_kernel", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dbinom_raw_opencl(int n_out, double x, double n_size, double prob, double qprob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dbinom_raw_kernel.cl"), "dbinom_raw_kernel", {x, n_size, prob, qprob, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dbinom_opencl(int n_out, double x, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dbinom_kernel.cl"), "dbinom_kernel", {x, size, prob, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pbinom_opencl(int n_out, double q, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pbinom_kernel.cl"), "pbinom_kernel", {q, size, prob, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnbinom_opencl(int n_out, double x, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnbinom_kernel.cl"), "dnbinom_kernel", {x, size, prob, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnbinom_opencl(int n_out, double q, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnbinom_kernel.cl"), "pnbinom_kernel", {q, size, prob, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnbinom_opencl(int n_out, double p, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnbinom_kernel.cl"), "qnbinom_kernel", {p, size, prob, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rnbinom_opencl(int n_out, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rnbinom_kernel.cl"), "rnbinom_kernel", {size, prob, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnbinom_mu_opencl(int n_out, double x, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnbinom_mu_kernel.cl"), "dnbinom_mu_kernel", {x, size, mu, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnbinom_mu_opencl(int n_out, double q, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnbinom_mu_kernel.cl"), "pnbinom_mu_kernel", {q, size, mu, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rmultinom_opencl(int n_out, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rmultinom_kernel.cl"), "rmultinom_kernel", {size, prob, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dcauchy_opencl(int n_out, double x, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dcauchy_kernel.cl"), "dcauchy_kernel", {x, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pcauchy_opencl(int n_out, double q, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pcauchy_kernel.cl"), "pcauchy_kernel", {q, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qcauchy_opencl(int n_out, double p, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qcauchy_kernel.cl"), "qcauchy_kernel", {p, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rcauchy_opencl(int n_out, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rcauchy_kernel.cl"), "rcauchy_kernel", {location, scale, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dexp_opencl(int n_out, double x, double rate, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dexp_kernel.cl"), "dexp_kernel", {x, rate, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pexp_opencl(int n_out, double q, double rate, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pexp_kernel.cl"), "pexp_kernel", {q, rate, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qexp_opencl(int n_out, double p, double rate, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qexp_kernel.cl"), "qexp_kernel", {p, rate, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dgeom_opencl(int n_out, double x, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dgeom_kernel.cl"), "dgeom_kernel", {x, prob, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pgeom_opencl(int n_out, double q, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pgeom_kernel.cl"), "pgeom_kernel", {q, prob, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qgeom_opencl(int n_out, double p, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qgeom_kernel.cl"), "qgeom_kernel", {p, prob, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rgeom_opencl(int n_out, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rgeom_kernel.cl"), "rgeom_kernel", {prob, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dhyper_opencl(int n_out, double x, double r, double b, double n1, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dhyper_kernel.cl"), "dhyper_kernel", {x, r, b, n1, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector phyper_opencl(int n_out, double q, double r, double b, double n1, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/phyper_kernel.cl"), "phyper_kernel", {q, r, b, n1, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qhyper_opencl(int n_out, double p, double r, double b, double n1, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qhyper_kernel.cl"), "qhyper_kernel", {p, r, b, n1, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rhyper_opencl(int n_out, double r, double b, double n1, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rhyper_kernel.cl"), "rhyper_kernel", {r, b, n1, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qbinom_opencl(int n_out, double p, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qbinom_kernel.cl"), "qbinom_kernel", {size, prob, p, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qpois_opencl(int n_out, double p, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qpois_kernel.cl"), "qpois_kernel", {0.0, 0.0, p, lambda}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dpois_raw_opencl(int n_out, double x, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dpois_raw_kernel.cl"), "dpois_raw_kernel", {x, lambda, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dpois_opencl(int n_out, double x, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dpois_kernel.cl"), "dpois_kernel", {x, lambda, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector ppois_opencl(int n_out, double q, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/ppois_kernel.cl"), "ppois_kernel", {q, lambda, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnbinom_mu_opencl(int n_out, double p, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnbinom_mu_kernel.cl"), "qnbinom_mu_kernel", {size, 0.0, p, mu}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rpois_opencl(int n_out, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rpois_kernel.cl"), "rpois_kernel", {0.0, 0.0, 0.0, lambda}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rnbinom_mu_opencl(int n_out, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rnbinom_mu_kernel.cl"), "rnbinom_mu_kernel", {size, mu, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dweibull_opencl(int n_out, double x, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dweibull_kernel.cl"), "dweibull_kernel", {x, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pweibull_opencl(int n_out, double q, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pweibull_kernel.cl"), "pweibull_kernel", {q, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qweibull_opencl(int n_out, double p, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qweibull_kernel.cl"), "qweibull_kernel", {p, shape, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rweibull_opencl(int n_out, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rweibull_kernel.cl"), "rweibull_kernel", {shape, scale, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dlogis_opencl(int n_out, double x, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dlogis_kernel.cl"), "dlogis_kernel", {x, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector plogis_opencl(int n_out, double q, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/plogis_kernel.cl"), "plogis_kernel", {q, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qlogis_opencl(int n_out, double p, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qlogis_kernel.cl"), "qlogis_kernel", {p, location, scale, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rlogis_opencl(int n_out, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rlogis_kernel.cl"), "rlogis_kernel", {location, scale, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnchisq_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnchisq_kernel.cl"), "pnchisq_kernel", {x, df, ncp, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnchisq_opencl(int n_out, double p, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnchisq_kernel.cl"), "qnchisq_kernel", {0.0, df, ncp, 0.0, p}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnf_opencl(int n_out, double x, double df1, double df2, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnf_kernel.cl"), "pnf_kernel", {x, df1, ncp, df2, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnf_opencl(int n_out, double x, double df1, double df2, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnf_kernel.cl"), "dnf_kernel", {x, df1, ncp, df2, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnf_opencl(int n_out, double p, double df1, double df2, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnf_kernel.cl"), "qnf_kernel", {0.0, df1, ncp, df2, p}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnbeta_opencl(int n_out, double x, double a, double b, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnbeta_kernel.cl"), "pnbeta_kernel", {x, a, ncp, b, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnbeta_opencl(int n_out, double p, double a, double b, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnbeta_kernel.cl"), "qnbeta_kernel", {0.0, a, ncp, b, p}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnbeta_opencl(int n_out, double x, double a, double b, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnbeta_kernel.cl"), "dnbeta_kernel", {x, a, ncp, b, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dnt_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dnt_kernel.cl"), "dnt_kernel", {x, df, ncp, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pnt_opencl(int n_out, double x, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pnt_kernel.cl"), "pnt_kernel", {x, df, ncp, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qnt_opencl(int n_out, double p, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qnt_kernel.cl"), "qnt_kernel", {0.0, df, ncp, 0.0, p}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector ptukey_opencl(int n_out, double q, double nmeans, double df, double nranges, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/ptukey_kernel.cl"), "ptukey_kernel", {q, nmeans, df, nranges, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qtukey_opencl(int n_out, double p, double nmeans, double df, double nranges, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qtukey_kernel.cl"), "qtukey_kernel", {p, nmeans, df, nranges, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dwilcox_opencl(int n_out, double x, double m, double n2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dwilcox_kernel.cl"), "dwilcox_kernel", {x, m, n2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pwilcox_opencl(int n_out, double q, double m, double n2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pwilcox_kernel.cl"), "pwilcox_kernel", {q, m, n2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qwilcox_opencl(int n_out, double p, double m, double n2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qwilcox_kernel.cl"), "qwilcox_kernel", {p, m, n2, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dsignrank_opencl(int n_out, double x, double nsize, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dsignrank_kernel.cl"), "dsignrank_kernel", {x, nsize, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector psignrank_opencl(int n_out, double q, double nsize, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/psignrank_kernel.cl"), "psignrank_kernel", {q, nsize, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector qsignrank_opencl(int n_out, double p, double nsize, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/qsignrank_kernel.cl"), "qsignrank_kernel", {p, nsize, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector rsignrank_opencl(int n_out, double nsize, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/rsignrank_kernel.cl"), "rsignrank_kernel", {nsize, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector gammafn_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/gammafn_kernel.cl"), "gammafn_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector lgammafn_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/lgammafn_kernel.cl"), "lgammafn_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector lgammafn_sign_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/lgammafn_sign_kernel.cl"), "lgammafn_sign_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector dpsifn_opencl(int n_out, double x, double n_deriv, double kode, double m, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/dpsifn_kernel.cl"), "dpsifn_kernel", {x, n_deriv, kode, m, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector psigamma_opencl(int n_out, double x, double deriv, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/psigamma_kernel.cl"), "psigamma_kernel", {x, deriv, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector digamma_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/digamma_kernel.cl"), "digamma_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector trigamma_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/trigamma_kernel.cl"), "trigamma_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector tetragamma_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/tetragamma_kernel.cl"), "tetragamma_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector pentagamma_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/pentagamma_kernel.cl"), "pentagamma_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector beta_opencl(int n_out, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/beta_special_kernel.cl"), "beta_special_kernel", {a, b, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector lbeta_opencl(int n_out, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/lbeta_special_kernel.cl"), "lbeta_special_kernel", {a, b, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector choose_opencl(int n_out, double n_val, double k, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/choose_special_kernel.cl"), "choose_special_kernel", {n_val, k, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector lchoose_opencl(int n_out, double n_val, double k, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/lchoose_special_kernel.cl"), "lchoose_special_kernel", {n_val, k, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_i_opencl(int n_out, double x, double nu, double expo_scaled, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_i_kernel.cl"), "bessel_i_kernel", {x, nu, expo_scaled, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_j_opencl(int n_out, double x, double nu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_j_kernel.cl"), "bessel_j_kernel", {x, nu, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_k_opencl(int n_out, double x, double nu, double expo_scaled, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_k_kernel.cl"), "bessel_k_kernel", {x, nu, expo_scaled, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_y_opencl(int n_out, double x, double nu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_y_kernel.cl"), "bessel_y_kernel", {x, nu, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_i_ex_opencl(int n_out, double x, double nu, double expo, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_i_ex_kernel.cl"), "bessel_i_ex_kernel", {x, nu, expo, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_j_ex_opencl(int n_out, double x, double nu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_j_ex_kernel.cl"), "bessel_j_ex_kernel", {x, nu, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_k_ex_opencl(int n_out, double x, double nu, double expo, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_k_ex_kernel.cl"), "bessel_k_ex_kernel", {x, nu, expo, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector bessel_y_ex_opencl(int n_out, double x, double nu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/bessel_y_ex_kernel.cl"), "bessel_y_ex_kernel", {x, nu, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector imax2_opencl(int n_out, double x, double y, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/imax2_kernel.cl"), "imax2_kernel", {x, y, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector imin2_opencl(int n_out, double x, double y, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/imin2_kernel.cl"), "imin2_kernel", {x, y, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector fmax2_opencl(int n_out, double x, double y, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/fmax2_kernel.cl"), "fmax2_kernel", {x, y, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector fmin2_opencl(int n_out, double x, double y, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/fmin2_kernel.cl"), "fmin2_kernel", {x, y, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector sign_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/sign_kernel.cl"), "sign_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector fprec_opencl(int n_out, double x, double digits, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/fprec_kernel.cl"), "fprec_kernel", {x, digits, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector fround_opencl(int n_out, double x, double digits, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/fround_kernel.cl"), "fround_kernel", {x, digits, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector fsign_opencl(int n_out, double x, double y, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/fsign_kernel.cl"), "fsign_kernel", {x, y, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector ftrunc_opencl(int n_out, double x, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/ftrunc_kernel.cl"), "ftrunc_kernel", {x, 0.0, 0.0, 0.0, 0.0}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_check_user_interrupt_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/r_check_user_interrupt_kernel.cl"), "r_check_user_interrupt_kernel", {}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

Rcpp::NumericVector r_check_stack_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try { std::vector<double> out_flat; opencl_dbl_scalar_kernel_runner(build_rmath_program_with_kernel("src/r_check_stack_kernel.cl"), "r_check_stack_kernel", {}, n_out, out_flat); for (int i = 0; i < n_out; ++i) out[i] = out_flat[(size_t)i]; } catch (const std::exception& e) { if (verbose) Rcpp::Rcout << e.what() << "\n"; throw; }
#endif
  return out;
}

} // namespace nmathopencl

