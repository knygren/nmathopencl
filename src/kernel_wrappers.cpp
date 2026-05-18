//#include <Rcpp.h>
#include <functional>
#include <vector>
#include <string>
#include "openclPort.h"
#include <RcppArmadillo.h>
#include "nmathopencl.h"

using namespace Rcpp;

using namespace openclPort;

namespace nmathopencl {

#ifdef USE_OPENCL
static std::string build_rmath_program_indexed(const std::string& kernel_rel_path);
static void opencl_serial_scalar_draws(
    const std::string& kernel_rel_path,
    const char* kernel_name,
    const std::vector<double>& dargs,
    int n_out,
    Rcpp::NumericVector& out,
    bool verbose);
#endif

Rcpp::NumericVector dnorm_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& mean,
    const Rcpp::NumericVector& sd,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dnorm_kernel.cl"),
          "dnorm_kernel",
          {x[i], mean[i], sd[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
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
    opencl_serial_scalar_draws("src/runif_kernel.cl", "runif_kernel", {a, b}, n, out, verbose);
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
    opencl_serial_scalar_draws("src/rnorm_kernel.cl", "rnorm_kernel", {mu, sigma}, n, out, verbose);
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
    opencl_serial_scalar_draws("src/rexp_kernel.cl", "rexp_kernel", {scale}, n, out, verbose);
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
    opencl_serial_scalar_draws("src/rwilcox_kernel.cl", "rwilcox_kernel", {m, n2}, n_out, out, verbose);
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
    opencl_serial_scalar_draws(
        "src/rbinom_kernel.cl", "rbinom_kernel", {size, prob}, n_out, out, verbose);
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

#ifdef USE_OPENCL
// Assemble OpenCL program: infrastructure shims + `inst/cl/nmath` stems from
// `@all_depends_nmath` via load_library_for_kernel() (kernel_dependency_index.tsv).
// Exceptions — full `load_kernel_library("nmath", ...)`: (1) kernels whose tags list
// `qDiscrete_search` (macro-expanded p* callees); (2) `norm_rand_kernel.cl` only
// (indexed slice omits sunif.cl → unresolved R_unif_index on NVPTX until closure improves).
static std::string build_rmath_program_indexed(const std::string& kernel_rel_path) {
  static const char norm_rand_suf[] = "norm_rand_kernel.cl";
  const std::size_t nrs = sizeof(norm_rand_suf) - 1;
  const bool norm_rand_launcher =
      kernel_rel_path.size() >= nrs &&
      kernel_rel_path.compare(kernel_rel_path.size() - nrs, nrs, norm_rand_suf) == 0;

  std::string nmath_src;
  if (kernel_all_depends_nmath_includes_qDiscrete_search(kernel_rel_path,
                                                          "nmathopencl") ||
      norm_rand_launcher) {
    nmath_src = load_kernel_library("nmath", "nmathopencl", false);
  } else {
    nmath_src = load_library_for_kernel(
        kernel_rel_path, "nmath", "nmathopencl", "all_depends_nmath");
  }
  return load_kernel_source("OPENCL.cl") +
    "\n" + load_kernel_library("libR_shims", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_types", "nmathopencl", false) +
    "\n" + load_kernel_library("R_shims", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_runtime", "nmathopencl", false) +
    "\n" + load_kernel_library("R_ext_internals", "nmathopencl", false) +
    "\n" + load_kernel_library("System", "nmathopencl", false) +
    "\n" + nmath_src +
    "\n" + load_kernel_source(kernel_rel_path);
}

// Match d/p/q: one scalar-output kernel launch per draw (program source built once).
static void opencl_serial_scalar_draws(
    const std::string& kernel_rel_path,
    const char* kernel_name,
    const std::vector<double>& dargs,
    int n_out,
    Rcpp::NumericVector& out,
    bool verbose
) {
  try {
    const std::string all_src = build_rmath_program_indexed(kernel_rel_path);
    for (int i = 0; i < n_out; ++i) {
      std::vector<double> one;
      opencl_dbl_scalar_kernel_runner(all_src, kernel_name, dargs, 1, one);
      out[i] = one[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
}

// Vectorized utilities: build program once; one scalar-output kernel launch per row.
static void opencl_serial_kernel_each_row(
    const std::string& kernel_rel_path,
    const char* kernel_name,
    int len,
    const std::function<std::vector<double>(int)>& dargs_at,
    Rcpp::NumericVector& out,
    bool verbose
) {
  try {
    const std::string all_src = build_rmath_program_indexed(kernel_rel_path);
    for (int i = 0; i < len; ++i) {
      std::vector<double> one;
      opencl_dbl_scalar_kernel_runner(all_src, kernel_name, dargs_at(i), 1, one);
      out[i] = one[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
}
#endif

Rcpp::NumericVector r_pow_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/r_pow_kernel.cl",
      "r_pow_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector r_pow_di_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::IntegerVector& n_exp,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(n_exp.size()) != len) {
    Rcpp::stop("INTERNAL: x and n_exp must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/r_pow_di_kernel.cl",
      "r_pow_di_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], static_cast<double>(n_exp[i]), 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1pmx_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/log1pmx_kernel.cl",
      "log1pmx_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1pexp_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/log1pexp_kernel.cl",
      "log1pexp_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1mexp_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/log1mexp_kernel.cl",
      "log1mexp_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgamma1p_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/lgamma1p_kernel.cl",
      "lgamma1p_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector pow1p_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/pow1p_kernel.cl",
      "pow1p_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector logspace_add_opencl(
    const Rcpp::NumericVector& logx,
    const Rcpp::NumericVector& logy,
    bool verbose
) {
  const int len = logx.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(logy.size()) != len) {
    Rcpp::stop("INTERNAL: logx and logy must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/logspace_add_kernel.cl",
      "logspace_add_kernel",
      len,
      [&](int i) { return std::vector<double>{logx[i], logy[i], 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector logspace_sub_opencl(
    const Rcpp::NumericVector& logx,
    const Rcpp::NumericVector& logy,
    bool verbose
) {
  const int len = logx.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(logy.size()) != len) {
    Rcpp::stop("INTERNAL: logx and logy must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/logspace_sub_kernel.cl",
      "logspace_sub_kernel",
      len,
      [&](int i) { return std::vector<double>{logx[i], logy[i], 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector logspace_sum_opencl(
    const Rcpp::NumericVector& logx,
    const Rcpp::NumericVector& logy,
    bool verbose
) {
  const int len = logx.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(logy.size()) != len) {
    Rcpp::stop("INTERNAL: logx and logy must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/logspace_sum_kernel.cl",
      "logspace_sum_kernel",
      len,
      [&](int i) { return std::vector<double>{logx[i], logy[i], 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector norm_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/norm_rand_kernel.cl", "norm_rand_kernel", {0.0, 1.0, 1.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector unif_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/unif_rand_kernel.cl", "unif_rand_kernel", {0.0, 1.0, 1.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector r_unif_index_opencl(int n_out, double dn, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/r_unif_index_kernel.cl", "r_unif_index_kernel", {0.0, 1.0, dn}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector exp_rand_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/exp_rand_kernel.cl", "exp_rand_kernel", {0.0, 1.0, 1.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pnorm_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& mean,
    const Rcpp::NumericVector& sd,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int    opencl_parallel_code,
    bool   verbose
) {
  (void)opencl_parallel_code;  // 0 serial, 1 parallel, 2 auto — reserved for dispatch
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;

  try {
    // -------------------------------------------------------------------------
    // Serial path (opencl_dbl_scalar_kernel_runner + pnorm_kernel), retained for revert:
    //
    // for (int i = 0; i < len; ++i) {
    //   const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
    //   const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
    //   std::vector<double> out_flat;
    //   opencl_dbl_scalar_kernel_runner(
    //       build_rmath_program_indexed("src/pnorm_kernel.cl"),
    //       "pnorm_kernel",
    //       {q[i], mean[i], sd[i], lt_d, lp_d},
    //       1,
    //       out_flat);
    //   out[i] = out_flat[0];
    // }
    // -------------------------------------------------------------------------
    std::vector<double> qv(q.begin(), q.end());
    std::vector<double> mv(mean.begin(), mean.end());
    std::vector<double> sv(sd.begin(), sd.end());
    std::vector<int> lt(lower_tail.begin(), lower_tail.end());
    std::vector<int> lp(log_p.begin(), log_p.end());

    std::vector<double> out_flat;
    opencl_pnorm_kernel_runner_temp(
        build_rmath_program_indexed("src/pnorm_kernel.cl"),
        "pnorm_kernel_temp",
        len,
        qv,
        mv,
        sv,
        lt,
        lp,
        out_flat);
    for (int i = 0; i < len; ++i) {
      out[i] = out_flat[static_cast<size_t>(i)];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

// Same OpenCL path as pnorm_opencl (NDRange + pnorm_kernel_temp); kept for experiments / diff tools.
Rcpp::NumericVector pnorm_opencl_temp(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& mean,
    const Rcpp::NumericVector& sd,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int opencl_parallel_code,
    bool verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;

  try {
    std::vector<double> qv(q.begin(), q.end());
    std::vector<double> mv(mean.begin(), mean.end());
    std::vector<double> sv(sd.begin(), sd.end());
    std::vector<int> lt(lower_tail.begin(), lower_tail.end());
    std::vector<int> lp(log_p.begin(), log_p.end());

    std::vector<double> out_flat;
    opencl_pnorm_kernel_runner_temp(
        build_rmath_program_indexed("src/pnorm_kernel.cl"),
        "pnorm_kernel_temp",
        len,
        qv,
        mv,
        sv,
        lt,
        lp,
        out_flat);
    for (int i = 0; i < len; ++i) {
      out[i] = out_flat[static_cast<size_t>(i)];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qnorm_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& mean,
    const Rcpp::NumericVector& sd,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qnorm_kernel.cl"),
          "qnorm_kernel",
          {p[i], mean[i], sd[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dunif_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& min,
    const Rcpp::NumericVector& max,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dunif_kernel.cl"),
          "dunif_kernel",
          {x[i], min[i], max[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector punif_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& min,
    const Rcpp::NumericVector& max,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/punif_kernel.cl"),
          "punif_kernel",
          {q[i], min[i], max[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qunif_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& min,
    const Rcpp::NumericVector& max,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qunif_kernel.cl"),
          "qunif_kernel",
          {p[i], min[i], max[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dgamma_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dgamma_kernel.cl"),
          "dgamma_kernel",
          {x[i], shape[i], scale[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pgamma_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pgamma_kernel.cl"),
          "pgamma_kernel",
          {q[i], shape[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qgamma_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qgamma_kernel.cl"),
          "qgamma_kernel",
          {p[i], shape[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rgamma_opencl(int n_out, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rgamma_kernel.cl", "rgamma_kernel", {shape, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dbeta_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& shape1,
    const Rcpp::NumericVector& shape2,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dbeta_kernel.cl"),
          "dbeta_kernel",
          {x[i], shape1[i], shape2[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pbeta_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape1,
    const Rcpp::NumericVector& shape2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pbeta_kernel.cl"),
            "pbeta_kernel",
            {q[i], shape1[i], shape2[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pnbeta_kernel.cl"),
            "pnbeta_kernel",
            {q[i], shape1[i], shape2[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qbeta_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& shape1,
    const Rcpp::NumericVector& shape2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qbeta_kernel.cl"),
            "qbeta_kernel",
            {p[i], shape1[i], shape2[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qnbeta_kernel.cl"),
            "qnbeta_kernel",
            {p[i], shape1[i], shape2[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rbeta_opencl(int n_out, double a, double b, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rbeta_kernel.cl", "rbeta_kernel", {a, b, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dlnorm_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& meanlog,
    const Rcpp::NumericVector& sdlog,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dlnorm_kernel.cl"),
          "dlnorm_kernel",
          {x[i], meanlog[i], sdlog[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector plnorm_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& meanlog,
    const Rcpp::NumericVector& sdlog,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/plnorm_kernel.cl"),
          "plnorm_kernel",
          {q[i], meanlog[i], sdlog[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qlnorm_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& meanlog,
    const Rcpp::NumericVector& sdlog,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qlnorm_kernel.cl"),
          "qlnorm_kernel",
          {p[i], meanlog[i], sdlog[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rlnorm_opencl(int n_out, double meanlog, double sdlog, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rlnorm_kernel.cl", "rlnorm_kernel", {meanlog, sdlog, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dchisq_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/dchisq_kernel.cl"),
            "dchisq_kernel",
            {x[i], df[i], gl_d, 0.0, 0.0},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/dnchisq_kernel.cl"),
            "dnchisq_kernel",
            {x[i], df[i], ncp[i], gl_d, 0.0},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pchisq_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pchisq_kernel.cl"),
            "pchisq_kernel",
            {q[i], df[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pnchisq_kernel.cl"),
            "pnchisq_kernel",
            {q[i], df[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qchisq_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qchisq_kernel.cl"),
            "qchisq_kernel",
            {p[i], df[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qnchisq_kernel.cl"),
            "qnchisq_kernel",
            {p[i], df[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rchisq_opencl(int n_out, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rchisq_kernel.cl", "rchisq_kernel", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rnchisq_opencl(int n_out, double df, double ncp, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rnchisq_kernel.cl", "rnchisq_kernel", {df, ncp, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector df_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& df1,
    const Rcpp::NumericVector& df2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/df_kernel.cl"),
            "df_kernel",
            {x[i], df1[i], df2[i], gl_d, 0.0},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/dnf_kernel.cl"),
            "dnf_kernel",
            {x[i], df1[i], ncp[i], df2[i], gl_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pf_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df1,
    const Rcpp::NumericVector& df2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pf_kernel.cl"),
            "pf_kernel",
            {q[i], df1[i], df2[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pnf_kernel.cl"),
            "pnf_kernel",
            {q[i], df1[i], df2[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qf_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& df1,
    const Rcpp::NumericVector& df2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qf_kernel.cl"),
            "qf_kernel",
            {p[i], df1[i], df2[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qnf_kernel.cl"),
            "qnf_kernel",
            {p[i], df1[i], df2[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rf_opencl(int n_out, double df1, double df2, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rf_kernel.cl", "rf_kernel", {df1, df2, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dt_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/dt_kernel.cl"),
            "dt_kernel",
            {x[i], df[i], gl_d, 0.0, 0.0},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/dnt_kernel.cl"),
            "dnt_kernel",
            {x[i], df[i], ncp[i], gl_d, 0.0},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pt_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pt_kernel.cl"),
            "pt_kernel",
            {q[i], df[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/pnt_kernel.cl"),
            "pnt_kernel",
            {q[i], df[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qt_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      if (ncp[i] == 0.0) {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qt_kernel.cl"),
            "qt_kernel",
            {p[i], df[i], lt_d, lp_d},
            1,
            out_flat);
      } else {
        opencl_dbl_scalar_kernel_runner(
            build_rmath_program_indexed("src/qnt_kernel.cl"),
            "qnt_kernel",
            {p[i], df[i], ncp[i], lt_d, lp_d},
            1,
            out_flat);
      }
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rt_opencl(int n_out, double df, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rt_kernel.cl", "rt_kernel", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dbinom_raw_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& n_size,
    const Rcpp::NumericVector& prob,
    const Rcpp::NumericVector& qprob,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dbinom_raw_kernel.cl"),
          "dbinom_raw_kernel",
          {x[i], n_size[i], prob[i], qprob[i], gl_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dbinom_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dbinom_kernel.cl"),
          "dbinom_kernel",
          {x[i], size[i], prob[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pbinom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pbinom_kernel.cl"),
          "pbinom_kernel",
          {q[i], size[i], prob[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dnbinom_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dnbinom_kernel.cl"),
          "dnbinom_kernel",
          {x[i], size[i], prob[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pnbinom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pnbinom_kernel.cl"),
          "pnbinom_kernel",
          {q[i], size[i], prob[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qnbinom_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qnbinom_kernel.cl"),
          "qnbinom_kernel",
          {p[i], size[i], prob[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rnbinom_opencl(int n_out, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rnbinom_kernel.cl", "rnbinom_kernel", {size, prob, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dnbinom_mu_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& mu,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dnbinom_mu_kernel.cl"),
          "dnbinom_mu_kernel",
          {x[i], size[i], mu[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pnbinom_mu_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& mu,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pnbinom_mu_kernel.cl"),
          "pnbinom_mu_kernel",
          {q[i], size[i], mu[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rmultinom_opencl(int n_out, double size, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rmultinom_kernel.cl", "rmultinom_kernel", {size, prob, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dcauchy_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dcauchy_kernel.cl"),
          "dcauchy_kernel",
          {x[i], location[i], scale[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pcauchy_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pcauchy_kernel.cl"),
          "pcauchy_kernel",
          {q[i], location[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qcauchy_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qcauchy_kernel.cl"),
          "qcauchy_kernel",
          {p[i], location[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rcauchy_opencl(int n_out, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rcauchy_kernel.cl", "rcauchy_kernel", {location, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dexp_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& rate,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dexp_kernel.cl"),
          "dexp_kernel",
          {x[i], rate[i], gl_d, 0.0, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pexp_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& rate,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pexp_kernel.cl"),
          "pexp_kernel",
          {q[i], rate[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qexp_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& rate,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qexp_kernel.cl"),
          "qexp_kernel",
          {p[i], rate[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dgeom_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dgeom_kernel.cl"),
          "dgeom_kernel",
          {x[i], prob[i], gl_d, 0.0, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pgeom_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pgeom_kernel.cl"),
          "pgeom_kernel",
          {q[i], prob[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qgeom_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qgeom_kernel.cl"),
          "qgeom_kernel",
          {p[i], prob[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rgeom_opencl(int n_out, double prob, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rgeom_kernel.cl", "rgeom_kernel", {prob, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dhyper_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& r,
    const Rcpp::NumericVector& b,
    const Rcpp::NumericVector& n1,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dhyper_kernel.cl"),
          "dhyper_kernel",
          {x[i], r[i], b[i], n1[i], gl_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector phyper_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n_black,
    const Rcpp::NumericVector& k,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/phyper_kernel.cl"),
          "phyper_kernel",
          {q[i], m[i], n_black[i], k[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qhyper_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& r,
    const Rcpp::NumericVector& b,
    const Rcpp::NumericVector& n1,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qhyper_kernel.cl"),
          "qhyper_kernel",
          {p[i], r[i], b[i], n1[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rhyper_opencl(int n_out, double r, double b, double n1, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rhyper_kernel.cl", "rhyper_kernel", {r, b, n1, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qbinom_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& prob,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qbinom_kernel.cl"),
          "qbinom_kernel",
          {size[i], prob[i], p[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qpois_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& lambda,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qpois_kernel.cl"),
          "qpois_kernel",
          {p[i], lambda[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dpois_raw_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& lambda,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dpois_raw_kernel.cl"),
          "dpois_raw_kernel",
          {x[i], lambda[i], gl_d, 0.0, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dpois_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& lambda,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dpois_kernel.cl"),
          "dpois_kernel",
          {x[i], lambda[i], gl_d, 0.0, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector ppois_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& lambda,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/ppois_kernel.cl"),
          "ppois_kernel",
          {q[i], lambda[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qnbinom_mu_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& size,
    const Rcpp::NumericVector& mu,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qnbinom_mu_kernel.cl"),
          "qnbinom_mu_kernel",
          {p[i], size[i], mu[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rpois_opencl(int n_out, double lambda, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rpois_kernel.cl", "rpois_kernel", {0.0, 0.0, 0.0, lambda}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rnbinom_mu_opencl(int n_out, double size, double mu, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rnbinom_mu_kernel.cl", "rnbinom_mu_kernel", {size, mu, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dweibull_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dweibull_kernel.cl"),
          "dweibull_kernel",
          {x[i], shape[i], scale[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pweibull_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pweibull_kernel.cl"),
          "pweibull_kernel",
          {q[i], shape[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qweibull_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& shape,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qweibull_kernel.cl"),
          "qweibull_kernel",
          {p[i], shape[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rweibull_opencl(int n_out, double shape, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rweibull_kernel.cl", "rweibull_kernel", {shape, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dlogis_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dlogis_kernel.cl"),
          "dlogis_kernel",
          {x[i], location[i], scale[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector plogis_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/plogis_kernel.cl"),
          "plogis_kernel",
          {q[i], location[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qlogis_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& location,
    const Rcpp::NumericVector& scale,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qlogis_kernel.cl"),
          "qlogis_kernel",
          {p[i], location[i], scale[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rlogis_opencl(int n_out, double location, double scale, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rlogis_kernel.cl", "rlogis_kernel", {location, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dnbeta_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& shape1,
    const Rcpp::NumericVector& shape2,
    const Rcpp::NumericVector& ncp,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dnbeta_kernel.cl"),
          "dnbeta_kernel",
          {x[i], shape1[i], ncp[i], shape2[i], gl_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector ptukey_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& nmeans,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& nranges,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/ptukey_kernel.cl"),
          "ptukey_kernel",
          {q[i], nmeans[i], df[i], nranges[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qtukey_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& nmeans,
    const Rcpp::NumericVector& df,
    const Rcpp::NumericVector& nranges,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qtukey_kernel.cl"),
          "qtukey_kernel",
          {p[i], nmeans[i], df[i], nranges[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dwilcox_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n2,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dwilcox_kernel.cl"),
          "dwilcox_kernel",
          {x[i], m[i], n2[i], gl_d, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector pwilcox_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n2,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/pwilcox_kernel.cl"),
          "pwilcox_kernel",
          {q[i], m[i], n2[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qwilcox_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& m,
    const Rcpp::NumericVector& n2,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qwilcox_kernel.cl"),
          "qwilcox_kernel",
          {p[i], m[i], n2[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector dsignrank_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nsize,
    const Rcpp::IntegerVector& give_log,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double gl_d = (give_log[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/dsignrank_kernel.cl"),
          "dsignrank_kernel",
          {x[i], nsize[i], gl_d, 0.0, 0.0},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector psignrank_opencl(
    const Rcpp::NumericVector& q,
    const Rcpp::NumericVector& nsize,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = q.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/psignrank_kernel.cl"),
          "psignrank_kernel",
          {q[i], nsize[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector qsignrank_opencl(
    const Rcpp::NumericVector& p,
    const Rcpp::NumericVector& nsize,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    int                          opencl_parallel_code,
    bool                         verbose
) {
  (void)opencl_parallel_code;
  const int len = p.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;

  try {
    for (int i = 0; i < len; ++i) {
      const double lt_d = (lower_tail[i] != 0) ? 1.0 : 0.0;
      const double lp_d = (log_p[i] != 0) ? 1.0 : 0.0;
      std::vector<double> out_flat;
      opencl_dbl_scalar_kernel_runner(
          build_rmath_program_indexed("src/qsignrank_kernel.cl"),
          "qsignrank_kernel",
          {p[i], nsize[i], lt_d, lp_d},
          1,
          out_flat);
      out[i] = out_flat[0];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rsignrank_opencl(int n_out, double nsize, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rsignrank_kernel.cl", "rsignrank_kernel", {nsize, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector gammafn_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/gammafn_kernel.cl",
      "gammafn_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgammafn_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/lgammafn_kernel.cl",
      "lgammafn_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgammafn_sign_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/lgammafn_sign_kernel.cl",
      "lgammafn_sign_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector dpsifn_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& n_deriv,
    const Rcpp::NumericVector& kode,
    const Rcpp::NumericVector& m,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(n_deriv.size()) != len || static_cast<int>(kode.size()) != len ||
      static_cast<int>(m.size()) != len) {
    Rcpp::stop("INTERNAL: x, n_deriv, kode, m must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/dpsifn_kernel.cl",
      "dpsifn_kernel",
      len,
      [&](int i) {
        return std::vector<double>{x[i], n_deriv[i], kode[i], m[i], 0.0};
      },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector psigamma_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& deriv,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(deriv.size()) != len) {
    Rcpp::stop("INTERNAL: x and deriv must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/psigamma_kernel.cl",
      "psigamma_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], deriv[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector digamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/digamma_kernel.cl",
      "digamma_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector trigamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/trigamma_kernel.cl",
      "trigamma_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector tetragamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/tetragamma_kernel.cl",
      "tetragamma_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector pentagamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/pentagamma_kernel.cl",
      "pentagamma_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector beta_opencl(
    const Rcpp::NumericVector& a,
    const Rcpp::NumericVector& b,
    bool verbose
) {
  const int len = a.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(b.size()) != len) {
    Rcpp::stop("INTERNAL: a and b must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/beta_special_kernel.cl",
      "beta_special_kernel",
      len,
      [&](int i) { return std::vector<double>{a[i], b[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lbeta_opencl(
    const Rcpp::NumericVector& a,
    const Rcpp::NumericVector& b,
    bool verbose
) {
  const int len = a.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(b.size()) != len) {
    Rcpp::stop("INTERNAL: a and b must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/lbeta_special_kernel.cl",
      "lbeta_special_kernel",
      len,
      [&](int i) { return std::vector<double>{a[i], b[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector choose_opencl(
    const Rcpp::NumericVector& n_val,
    const Rcpp::NumericVector& k,
    bool verbose
) {
  const int len = n_val.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(k.size()) != len) {
    Rcpp::stop("INTERNAL: n_val and k must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/choose_special_kernel.cl",
      "choose_special_kernel",
      len,
      [&](int i) { return std::vector<double>{n_val[i], k[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lchoose_opencl(
    const Rcpp::NumericVector& n_val,
    const Rcpp::NumericVector& k,
    bool verbose
) {
  const int len = n_val.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(k.size()) != len) {
    Rcpp::stop("INTERNAL: n_val and k must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/lchoose_special_kernel.cl",
      "lchoose_special_kernel",
      len,
      [&](int i) { return std::vector<double>{n_val[i], k[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_i_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    const Rcpp::NumericVector& expo_scaled,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len || static_cast<int>(expo_scaled.size()) != len) {
    Rcpp::stop("INTERNAL: x, nu, expo_scaled must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_i_kernel.cl",
      "bessel_i_kernel",
      len,
      [&](int i) {
        return std::vector<double>{x[i], nu[i], expo_scaled[i], 0.0, 0.0};
      },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_j_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len) {
    Rcpp::stop("INTERNAL: x and nu must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_j_kernel.cl",
      "bessel_j_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_k_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    const Rcpp::NumericVector& expo_scaled,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len || static_cast<int>(expo_scaled.size()) != len) {
    Rcpp::stop("INTERNAL: x, nu, expo_scaled must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_k_kernel.cl",
      "bessel_k_kernel",
      len,
      [&](int i) {
        return std::vector<double>{x[i], nu[i], expo_scaled[i], 0.0, 0.0};
      },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_y_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len) {
    Rcpp::stop("INTERNAL: x and nu must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_y_kernel.cl",
      "bessel_y_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_i_ex_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    const Rcpp::NumericVector& expo,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len || static_cast<int>(expo.size()) != len) {
    Rcpp::stop("INTERNAL: x, nu, expo must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_i_ex_kernel.cl",
      "bessel_i_ex_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], expo[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_j_ex_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len) {
    Rcpp::stop("INTERNAL: x and nu must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_j_ex_kernel.cl",
      "bessel_j_ex_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_k_ex_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    const Rcpp::NumericVector& expo,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len || static_cast<int>(expo.size()) != len) {
    Rcpp::stop("INTERNAL: x, nu, expo must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_k_ex_kernel.cl",
      "bessel_k_ex_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], expo[i], 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector bessel_y_ex_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& nu,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(nu.size()) != len) {
    Rcpp::stop("INTERNAL: x and nu must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/bessel_y_ex_kernel.cl",
      "bessel_y_ex_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], nu[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector imax2_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/imax2_kernel.cl",
      "imax2_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector imin2_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/imin2_kernel.cl",
      "imin2_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector fmax2_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/fmax2_kernel.cl",
      "fmax2_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector fmin2_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/fmin2_kernel.cl",
      "fmin2_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector sign_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/sign_kernel.cl",
      "sign_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector fprec_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& digits,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(digits.size()) != len) {
    Rcpp::stop("INTERNAL: x and digits must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/fprec_kernel.cl",
      "fprec_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], digits[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector fround_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& digits,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(digits.size()) != len) {
    Rcpp::stop("INTERNAL: x and digits must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/fround_kernel.cl",
      "fround_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], digits[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector fsign_opencl(
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& y,
    bool verbose
) {
  const int len = x.size();
  if (len == 0) {
    return Rcpp::NumericVector(0);
  }
  if (static_cast<int>(y.size()) != len) {
    Rcpp::stop("INTERNAL: x and y must have identical length.");
  }
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/fsign_kernel.cl",
      "fsign_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], y[i], 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector ftrunc_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  opencl_serial_kernel_each_row(
      "src/ftrunc_kernel.cl",
      "ftrunc_kernel",
      len,
      [&](int i) { return std::vector<double>{x[i], 0.0, 0.0, 0.0, 0.0}; },
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector r_check_user_interrupt_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/r_check_user_interrupt_kernel.cl", "r_check_user_interrupt_kernel", {}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector r_check_stack_opencl(int n_out, bool verbose) {
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/r_check_stack_kernel.cl", "r_check_stack_kernel", {}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

} // namespace nmathopencl

