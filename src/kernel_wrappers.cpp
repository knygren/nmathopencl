//#include <Rcpp.h>
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
    const char* kernel_temp_name,
    const std::vector<double>& dargs,
    int n_out,
    Rcpp::NumericVector& out,
    bool verbose);
static void d_givelog_ndrange_kernel_temp_fill(
    const char* kernel_rel_path,
    const char* kernel_temp_name,
    int len,
    const std::vector<const Rcpp::NumericVector*>& numeric_args,
    const Rcpp::IntegerVector& give_log,
    Rcpp::NumericVector& out,
    bool verbose);
static void pq_tail_ndrange_kernel_temp_fill(
    const char* kernel_rel_path,
    const char* kernel_temp_name,
    int len,
    const std::vector<const Rcpp::NumericVector*>& numeric_args,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    Rcpp::NumericVector& out,
    bool verbose);
static void numeric_cols_ndrange_kernel_temp_fill(
    const char*                                          kernel_rel_path,
    const char*                                          kernel_temp_name,
    int                                                  len,
    const std::vector<const Rcpp::NumericVector*>&        numeric_args,
    Rcpp::NumericVector&                                 out,
    bool                                                 verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dnorm_kernel.cl",
        "dnorm_kernel_temp",
        len,
        {&x, &mean, &sd},
        give_log,
        out,
        verbose);
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
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws("src/runif_kernel.cl", "runif_kernel_temp", {a, b}, n, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rnorm_opencl(
    int    n,
    double mu,
    double sigma,
    bool   verbose
) {
  if (n < 0) Rcpp::stop("`n` must be >= 0.");
  Rcpp::NumericVector out(n);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws("src/rnorm_kernel.cl", "rnorm_kernel_temp", {mu, sigma}, n, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rexp_opencl(
    int    n,
    double scale,
    bool   verbose
) {
  if (n < 0) Rcpp::stop("`n` must be >= 0.");
  Rcpp::NumericVector out(n);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws("src/rexp_kernel.cl", "rexp_kernel_temp", {scale}, n, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rwilcox_opencl(
    int    n_out,
    double m,
    double n2,
    bool   verbose
) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws("src/rwilcox_kernel.cl", "rwilcox_kernel_temp", {m, n2}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

Rcpp::NumericVector rbinom_opencl(
    int    n_out,
    double size,
    double prob,
    bool   verbose
) {
  if (n_out < 0) Rcpp::stop("`n_out` must be >= 0.");
  Rcpp::NumericVector out(n_out);
#ifdef USE_OPENCL
  if (!has_opencl()) return out;
  try {
    opencl_serial_scalar_draws(
        "src/rbinom_kernel.cl", "rbinom_kernel_temp", {size, prob}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
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

// Match d/p/q: build program once, then *_kernel_temp (serial RNG inner loop).
static void opencl_serial_scalar_draws(
    const std::string& kernel_rel_path,
    const char* kernel_temp_name,
    const std::vector<double>& dargs,
    int n_out,
    Rcpp::NumericVector& out,
    bool verbose
) {
  if (n_out <= 0) return;
  try {
    const std::string all_src = build_rmath_program_indexed(kernel_rel_path);
    /*
    Legacy path: one GPU session + compile + enqueue per scalar draw (slow).
    for (int i = 0; i < n_out; ++i) {
      std::vector<double> one;
      opencl_dbl_scalar_kernel_runner(all_src, "foo_kernel", dargs, 1, one);
      out[i] = one[0];
    }
    */
    std::vector<double> flat(static_cast<size_t>(n_out));
    opencl_dbl_scalar_kernel_runner(all_src, kernel_temp_name, dargs, n_out, flat);
    for (int i = 0; i < n_out; ++i) {
      out[i] = flat[static_cast<size_t>(i)];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
}

// NDRange *_kernel_temp helpers (lower.tail / log.p as int columns).
static std::vector<std::vector<double>> pq_pack_numeric_cols_for_tail_temp(
    const std::vector<const Rcpp::NumericVector*>& cols
) {
  std::vector<std::vector<double>> out;
  out.reserve(cols.size());
  for (const Rcpp::NumericVector* v : cols) {
    out.emplace_back(v->begin(), v->end());
  }
  return out;
}

static void pq_tail_ndrange_kernel_temp_fill(
    const char* kernel_rel_path,
    const char* kernel_temp_name,
    int len,
    const std::vector<const Rcpp::NumericVector*>& numeric_args,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    Rcpp::NumericVector& out,
    bool verbose
) {
  (void)verbose;
  std::vector<std::vector<double>> arg_cols =
      pq_pack_numeric_cols_for_tail_temp(numeric_args);
  std::vector<int> lt(lower_tail.begin(), lower_tail.end());
  std::vector<int> lp(log_p.begin(), log_p.end());
  std::vector<double> out_flat;
  opencl_pq_tail_kernel_runner_temp(
      build_rmath_program_indexed(kernel_rel_path),
      kernel_temp_name,
      len,
      arg_cols,
      lt,
      lp,
      out_flat);
  for (int i = 0; i < len; ++i) {
    out[i] = out_flat[static_cast<size_t>(i)];
  }
}

static void d_givelog_ndrange_kernel_temp_fill(
    const char*                                            kernel_rel_path,
    const char*                                            kernel_temp_name,
    int                                                    len,
    const std::vector<const Rcpp::NumericVector*>&          numeric_args,
    const Rcpp::IntegerVector&                             give_log,
    Rcpp::NumericVector&                                   out,
    bool                                                   verbose
) {
  (void)verbose;
  std::vector<std::vector<double>> arg_cols =
      pq_pack_numeric_cols_for_tail_temp(numeric_args);
  std::vector<int> gl(give_log.begin(), give_log.end());
  std::vector<double> out_flat;
  opencl_d_givelog_kernel_runner_temp(
      build_rmath_program_indexed(kernel_rel_path),
      kernel_temp_name,
      len,
      arg_cols,
      gl,
      out_flat);
  for (int i = 0; i < len; ++i) {
    out[i] = out_flat[static_cast<size_t>(i)];
  }
}

static void numeric_cols_ndrange_kernel_temp_fill(
    const char*                                           kernel_rel_path,
    const char*                                           kernel_temp_name,
    int                                                   len,
    const std::vector<const Rcpp::NumericVector*>&         numeric_args,
    Rcpp::NumericVector&                                  out,
    bool                                                  verbose
) {
  try {
    std::vector<std::vector<double>> arg_cols =
        pq_pack_numeric_cols_for_tail_temp(numeric_args);
    std::vector<double> out_flat;
    opencl_numeric_cols_kernel_runner_temp(
        build_rmath_program_indexed(kernel_rel_path),
        kernel_temp_name,
        len,
        arg_cols,
        out_flat);
    for (int i = 0; i < len; ++i) {
      out[i] = out_flat[static_cast<size_t>(i)];
    }
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
}

// Mixed ncp (some rows central, some non-central): partition rows, run up to two
// vectored *_kernel_temp enqueues on packed buffers, scatter back into full `out`.
static Rcpp::IntegerVector gather_int_at_ix(
    const std::vector<int>& ix, const Rcpp::IntegerVector& v
) {
  const int nk = static_cast<int>(ix.size());
  Rcpp::IntegerVector o(nk);
  for (int j = 0; j < nk; ++j) {
    o[j] = v[ix[static_cast<size_t>(j)]];
  }
  return o;
}

static Rcpp::NumericVector gather_num_at_ix(
    const std::vector<int>& ix, const Rcpp::NumericVector& v
) {
  const int nk = static_cast<int>(ix.size());
  Rcpp::NumericVector o(nk);
  for (int j = 0; j < nk; ++j) {
    o[j] = v[ix[static_cast<size_t>(j)]];
  }
  return o;
}

/** Partition row indices where ncp[i] == 0 (central) vs ncp[i] != 0. */
static void ncp_partition_zero_vs_positive(
    int len, const Rcpp::NumericVector& ncp, std::vector<int>* idx_z, std::vector<int>* idx_n
) {
  idx_z->clear();
  idx_n->clear();
  idx_z->reserve(static_cast<size_t>(len));
  idx_n->reserve(static_cast<size_t>(len));
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0)
      idx_z->push_back(i);
    else
      idx_n->push_back(i);
  }
}

// Mixed ncp vector: central kernels use three numeric buffers; non-central adds ncp (+4 cols).
static void pq_mixed_ncp_three_four_ndrange_twopass(
    const char* path_z,
    const char* ker_z,
    const char* path_n,
    const char* ker_n,
    int len,
    const Rcpp::NumericVector& ncp,
    const Rcpp::NumericVector& v0,
    const Rcpp::NumericVector& v1,
    const Rcpp::NumericVector& v2,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    Rcpp::NumericVector&       out,
    bool                       verbose
) {
  std::vector<int> iz;
  std::vector<int> in_;
  ncp_partition_zero_vs_positive(len, ncp, &iz, &in_);
  const int nz = static_cast<int>(iz.size());
  const int nn = static_cast<int>(in_.size());

  if (nz > 0) {
    Rcpp::NumericVector az = gather_num_at_ix(iz, v0);
    Rcpp::NumericVector bz = gather_num_at_ix(iz, v1);
    Rcpp::NumericVector cz = gather_num_at_ix(iz, v2);
    Rcpp::IntegerVector ltz = gather_int_at_ix(iz, lower_tail);
    Rcpp::IntegerVector lpz = gather_int_at_ix(iz, log_p);
    Rcpp::NumericVector oz(nz);
    pq_tail_ndrange_kernel_temp_fill(
        path_z, ker_z, nz, {&az, &bz, &cz}, ltz, lpz, oz, verbose);
    for (int j = 0; j < nz; ++j) out[iz[static_cast<size_t>(j)]] = oz[j];
  }
  if (nn > 0) {
    Rcpp::NumericVector an = gather_num_at_ix(in_, v0);
    Rcpp::NumericVector bn = gather_num_at_ix(in_, v1);
    Rcpp::NumericVector cn = gather_num_at_ix(in_, v2);
    Rcpp::NumericVector nnv = gather_num_at_ix(in_, ncp);
    Rcpp::IntegerVector ltn = gather_int_at_ix(in_, lower_tail);
    Rcpp::IntegerVector lpn = gather_int_at_ix(in_, log_p);
    Rcpp::NumericVector on(nn);
    pq_tail_ndrange_kernel_temp_fill(
        path_n, ker_n, nn, {&an, &bn, &cn, &nnv}, ltn, lpn, on, verbose);
    for (int j = 0; j < nn; ++j) out[in_[static_cast<size_t>(j)]] = on[j];
  }
}

// Mixed ncp vector: central two numeric buffers vs non-central three (adds ncp).
static void pq_mixed_ncp_two_three_ndrange_twopass(
    const char* path_z,
    const char* ker_z,
    const char* path_n,
    const char* ker_n,
    int len,
    const Rcpp::NumericVector& ncp,
    const Rcpp::NumericVector& v0,
    const Rcpp::NumericVector& v1,
    const Rcpp::IntegerVector& lower_tail,
    const Rcpp::IntegerVector& log_p,
    Rcpp::NumericVector&       out,
    bool                       verbose
) {
  std::vector<int> iz;
  std::vector<int> in_;
  ncp_partition_zero_vs_positive(len, ncp, &iz, &in_);
  const int nz = static_cast<int>(iz.size());
  const int nn = static_cast<int>(in_.size());

  if (nz > 0) {
    Rcpp::NumericVector az = gather_num_at_ix(iz, v0);
    Rcpp::NumericVector bz = gather_num_at_ix(iz, v1);
    Rcpp::IntegerVector ltz = gather_int_at_ix(iz, lower_tail);
    Rcpp::IntegerVector lpz = gather_int_at_ix(iz, log_p);
    Rcpp::NumericVector oz(nz);
    pq_tail_ndrange_kernel_temp_fill(path_z, ker_z, nz, {&az, &bz}, ltz, lpz, oz, verbose);
    for (int j = 0; j < nz; ++j) out[iz[static_cast<size_t>(j)]] = oz[j];
  }
  if (nn > 0) {
    Rcpp::NumericVector an = gather_num_at_ix(in_, v0);
    Rcpp::NumericVector bn = gather_num_at_ix(in_, v1);
    Rcpp::NumericVector nnv = gather_num_at_ix(in_, ncp);
    Rcpp::IntegerVector ltn = gather_int_at_ix(in_, lower_tail);
    Rcpp::IntegerVector lpn = gather_int_at_ix(in_, log_p);
    Rcpp::NumericVector on(nn);
    pq_tail_ndrange_kernel_temp_fill(path_n, ker_n, nn, {&an, &bn, &nnv}, ltn, lpn, on, verbose);
    for (int j = 0; j < nn; ++j) out[in_[static_cast<size_t>(j)]] = on[j];
  }
}

// Density with give_log: two numeric columns (central) vs three (non-central adds ncp).
static void dg_mixed_ncp_two_three_ndrange_twopass(
    const char* path_z,
    const char* ker_z,
    const char* path_n,
    const char* ker_n,
    int len,
    const Rcpp::NumericVector& ncp,
    const Rcpp::NumericVector& v0,
    const Rcpp::NumericVector& v1,
    const Rcpp::IntegerVector& give_log,
    Rcpp::NumericVector& out,
    bool                   verbose
) {
  std::vector<int> iz;
  std::vector<int> in_;
  ncp_partition_zero_vs_positive(len, ncp, &iz, &in_);
  const int nz = static_cast<int>(iz.size());
  const int nn = static_cast<int>(in_.size());

  if (nz > 0) {
    Rcpp::NumericVector az = gather_num_at_ix(iz, v0);
    Rcpp::NumericVector bz = gather_num_at_ix(iz, v1);
    Rcpp::IntegerVector glz = gather_int_at_ix(iz, give_log);
    Rcpp::NumericVector oz(nz);
    d_givelog_ndrange_kernel_temp_fill(path_z, ker_z, nz, {&az, &bz}, glz, oz, verbose);
    for (int j = 0; j < nz; ++j) out[iz[static_cast<size_t>(j)]] = oz[j];
  }
  if (nn > 0) {
    Rcpp::NumericVector an = gather_num_at_ix(in_, v0);
    Rcpp::NumericVector bn = gather_num_at_ix(in_, v1);
    Rcpp::NumericVector nc = gather_num_at_ix(in_, ncp);
    Rcpp::IntegerVector gln = gather_int_at_ix(in_, give_log);
    Rcpp::NumericVector on(nn);
    d_givelog_ndrange_kernel_temp_fill(path_n, ker_n, nn, {&an, &bn, &nc}, gln, on, verbose);
    for (int j = 0; j < nn; ++j) out[in_[static_cast<size_t>(j)]] = on[j];
  }
}

/** df vs dnf: central (x,df1,df2); non-central OpenCL buffers are (x,df1,ncp,df2). */
static void df_nf_mixed_ncp_ndrange_twopass(
    int len,
    const Rcpp::NumericVector& ncp,
    const Rcpp::NumericVector& x,
    const Rcpp::NumericVector& df1,
    const Rcpp::NumericVector& df2,
    const Rcpp::IntegerVector& give_log,
    Rcpp::NumericVector&       out,
    bool                       verbose
) {
  std::vector<int> iz;
  std::vector<int> in_;
  ncp_partition_zero_vs_positive(len, ncp, &iz, &in_);
  const int nz = static_cast<int>(iz.size());
  const int nn = static_cast<int>(in_.size());

  if (nz > 0) {
    Rcpp::NumericVector xz = gather_num_at_ix(iz, x);
    Rcpp::NumericVector df1z = gather_num_at_ix(iz, df1);
    Rcpp::NumericVector df2z = gather_num_at_ix(iz, df2);
    Rcpp::IntegerVector glz = gather_int_at_ix(iz, give_log);
    Rcpp::NumericVector oz(nz);
    d_givelog_ndrange_kernel_temp_fill(
        "src/df_kernel.cl", "df_kernel_temp", nz, {&xz, &df1z, &df2z}, glz, oz, verbose);
    for (int j = 0; j < nz; ++j) out[iz[static_cast<size_t>(j)]] = oz[j];
  }
  if (nn > 0) {
    Rcpp::NumericVector xn = gather_num_at_ix(in_, x);
    Rcpp::NumericVector df1n = gather_num_at_ix(in_, df1);
    Rcpp::NumericVector df2n = gather_num_at_ix(in_, df2);
    Rcpp::NumericVector ncn = gather_num_at_ix(in_, ncp);
    Rcpp::IntegerVector gln = gather_int_at_ix(in_, give_log);
    Rcpp::NumericVector on(nn);
    d_givelog_ndrange_kernel_temp_fill(
        "src/dnf_kernel.cl",
        "dnf_kernel_temp",
        nn,
        {&xn, &df1n, &ncn, &df2n},
        gln,
        on,
        verbose);
    for (int j = 0; j < nn; ++j) out[in_[static_cast<size_t>(j)]] = on[j];
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/r_pow_kernel.cl",
      "r_pow_kernel_temp",
      len,
      {&x, &y},
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
  Rcpp::NumericVector n_exp_d(len);
  for (int i = 0; i < len; ++i) {
    n_exp_d[i] = static_cast<double>(n_exp[i]);
  }
  numeric_cols_ndrange_kernel_temp_fill(
      "src/r_pow_di_kernel.cl",
      "r_pow_di_kernel_temp",
      len,
      {&x, &n_exp_d},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1pmx_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/log1pmx_kernel.cl",
      "log1pmx_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1pexp_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/log1pexp_kernel.cl",
      "log1pexp_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector log1mexp_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/log1mexp_kernel.cl",
      "log1mexp_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgamma1p_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/lgamma1p_kernel.cl",
      "lgamma1p_kernel_temp",
      len,
      {&x},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/pow1p_kernel.cl",
      "pow1p_kernel_temp",
      len,
      {&x, &y},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/logspace_add_kernel.cl",
      "logspace_add_kernel_temp",
      len,
      {&logx, &logy},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/logspace_sub_kernel.cl",
      "logspace_sub_kernel_temp",
      len,
      {&logx, &logy},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/logspace_sum_kernel.cl",
      "logspace_sum_kernel_temp",
      len,
      {&logx, &logy},
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
        "src/norm_rand_kernel.cl", "norm_rand_kernel_temp", {0.0, 1.0, 1.0}, n_out, out, verbose);
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
        "src/unif_rand_kernel.cl", "unif_rand_kernel_temp", {0.0, 1.0, 1.0}, n_out, out, verbose);
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
        "src/r_unif_index_kernel.cl", "r_unif_index_kernel_temp", {0.0, 1.0, dn}, n_out, out, verbose);
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
        "src/exp_rand_kernel.cl", "exp_rand_kernel_temp", {0.0, 1.0, 1.0}, n_out, out, verbose);
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
    pq_tail_ndrange_kernel_temp_fill(
        "src/pnorm_kernel.cl",
        "pnorm_kernel",
        len,
        {&q, &mean, &sd},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qnorm_kernel.cl",
        "qnorm_kernel_temp",
        len,
        {&p, &mean, &sd},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dunif_kernel.cl",
        "dunif_kernel_temp",
        len,
        {&x, &min, &max},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/punif_kernel.cl",
        "punif_kernel",
        len,
        {&q, &min, &max},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qunif_kernel.cl",
        "qunif_kernel_temp",
        len,
        {&p, &min, &max},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dgamma_kernel.cl",
        "dgamma_kernel_temp",
        len,
        {&x, &shape, &scale},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pgamma_kernel.cl",
        "pgamma_kernel",
        len,
        {&q, &shape, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qgamma_kernel.cl",
        "qgamma_kernel_temp",
        len,
        {&p, &shape, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rgamma_kernel.cl", "rgamma_kernel_temp", {shape, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dbeta_kernel.cl",
        "dbeta_kernel_temp",
        len,
        {&x, &shape1, &shape2},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pbeta_kernel.cl",
          "pbeta_kernel",
          len,
          {&q, &shape1, &shape2},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pnbeta_kernel.cl",
          "pnbeta_kernel",
          len,
          {&q, &shape1, &shape2, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_three_four_ndrange_twopass(
          "src/pbeta_kernel.cl",
          "pbeta_kernel",
          "src/pnbeta_kernel.cl",
          "pnbeta_kernel",
          len,
          ncp,
          q,
          shape1,
          shape2,
          lower_tail,
          log_p,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qbeta_kernel.cl",
          "qbeta_kernel_temp",
          len,
          {&p, &shape1, &shape2},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qnbeta_kernel.cl",
          "qnbeta_kernel_temp",
          len,
          {&p, &shape1, &shape2, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_three_four_ndrange_twopass(
          "src/qbeta_kernel.cl",
          "qbeta_kernel_temp",
          "src/qnbeta_kernel.cl",
          "qnbeta_kernel_temp",
          len,
          ncp,
          p,
          shape1,
          shape2,
          lower_tail,
          log_p,
          out,
          verbose);
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
        "src/rbeta_kernel.cl", "rbeta_kernel_temp", {a, b, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dlnorm_kernel.cl",
        "dlnorm_kernel_temp",
        len,
        {&x, &meanlog, &sdlog},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/plnorm_kernel.cl",
        "plnorm_kernel",
        len,
        {&q, &meanlog, &sdlog},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qlnorm_kernel.cl",
        "qlnorm_kernel_temp",
        len,
        {&p, &meanlog, &sdlog},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rlnorm_kernel.cl", "rlnorm_kernel_temp", {meanlog, sdlog, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/dchisq_kernel.cl",
          "dchisq_kernel_temp",
          len,
          {&x, &df},
          give_log,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/dnchisq_kernel.cl",
          "dnchisq_kernel_temp",
          len,
          {&x, &df, &ncp},
          give_log,
          out,
          verbose);
    } else {
      dg_mixed_ncp_two_three_ndrange_twopass(
          "src/dchisq_kernel.cl",
          "dchisq_kernel_temp",
          "src/dnchisq_kernel.cl",
          "dnchisq_kernel_temp",
          len,
          ncp,
          x,
          df,
          give_log,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pchisq_kernel.cl",
          "pchisq_kernel",
          len,
          {&q, &df},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pnchisq_kernel.cl",
          "pnchisq_kernel",
          len,
          {&q, &df, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_two_three_ndrange_twopass(
          "src/pchisq_kernel.cl",
          "pchisq_kernel",
          "src/pnchisq_kernel.cl",
          "pnchisq_kernel",
          len,
          ncp,
          q,
          df,
          lower_tail,
          log_p,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qchisq_kernel.cl",
          "qchisq_kernel_temp",
          len,
          {&p, &df},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qnchisq_kernel.cl",
          "qnchisq_kernel_temp",
          len,
          {&p, &df, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_two_three_ndrange_twopass(
          "src/qchisq_kernel.cl",
          "qchisq_kernel_temp",
          "src/qnchisq_kernel.cl",
          "qnchisq_kernel_temp",
          len,
          ncp,
          p,
          df,
          lower_tail,
          log_p,
          out,
          verbose);
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
        "src/rchisq_kernel.cl", "rchisq_kernel_temp", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
        "src/rnchisq_kernel.cl", "rnchisq_kernel_temp", {df, ncp, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/df_kernel.cl",
          "df_kernel_temp",
          len,
          {&x, &df1, &df2},
          give_log,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/dnf_kernel.cl",
          "dnf_kernel_temp",
          len,
          {&x, &df1, &ncp, &df2},
          give_log,
          out,
          verbose);
    } else {
      df_nf_mixed_ncp_ndrange_twopass(len, ncp, x, df1, df2, give_log, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pf_kernel.cl",
          "pf_kernel",
          len,
          {&q, &df1, &df2},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pnf_kernel.cl",
          "pnf_kernel",
          len,
          {&q, &df1, &df2, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_three_four_ndrange_twopass(
          "src/pf_kernel.cl",
          "pf_kernel",
          "src/pnf_kernel.cl",
          "pnf_kernel",
          len,
          ncp,
          q,
          df1,
          df2,
          lower_tail,
          log_p,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qf_kernel.cl",
          "qf_kernel_temp",
          len,
          {&p, &df1, &df2},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qnf_kernel.cl",
          "qnf_kernel_temp",
          len,
          {&p, &df1, &df2, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_three_four_ndrange_twopass(
          "src/qf_kernel.cl",
          "qf_kernel_temp",
          "src/qnf_kernel.cl",
          "qnf_kernel_temp",
          len,
          ncp,
          p,
          df1,
          df2,
          lower_tail,
          log_p,
          out,
          verbose);
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
        "src/rf_kernel.cl", "rf_kernel_temp", {df1, df2, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/dt_kernel.cl",
          "dt_kernel_temp",
          len,
          {&x, &df},
          give_log,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      d_givelog_ndrange_kernel_temp_fill(
          "src/dnt_kernel.cl",
          "dnt_kernel_temp",
          len,
          {&x, &df, &ncp},
          give_log,
          out,
          verbose);
    } else {
      dg_mixed_ncp_two_three_ndrange_twopass(
          "src/dt_kernel.cl",
          "dt_kernel_temp",
          "src/dnt_kernel.cl",
          "dnt_kernel_temp",
          len,
          ncp,
          x,
          df,
          give_log,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pt_kernel.cl",
          "pt_kernel",
          len,
          {&q, &df},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/pnt_kernel.cl",
          "pnt_kernel",
          len,
          {&q, &df, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_two_three_ndrange_twopass(
          "src/pt_kernel.cl",
          "pt_kernel",
          "src/pnt_kernel.cl",
          "pnt_kernel",
          len,
          ncp,
          q,
          df,
          lower_tail,
          log_p,
          out,
          verbose);
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
  if (!has_opencl() || len == 0) return out;

  bool all_ncp_zero = true;
  bool any_ncp_zero = false;
  for (int i = 0; i < len; ++i) {
    if (ncp[i] == 0.0) {
      any_ncp_zero = true;
    } else {
      all_ncp_zero = false;
    }
  }

  try {
    if (all_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qt_kernel.cl",
          "qt_kernel_temp",
          len,
          {&p, &df},
          lower_tail,
          log_p,
          out,
          verbose);
    } else if (!any_ncp_zero) {
      pq_tail_ndrange_kernel_temp_fill(
          "src/qnt_kernel.cl",
          "qnt_kernel_temp",
          len,
          {&p, &df, &ncp},
          lower_tail,
          log_p,
          out,
          verbose);
    } else {
      pq_mixed_ncp_two_three_ndrange_twopass(
          "src/qt_kernel.cl",
          "qt_kernel_temp",
          "src/qnt_kernel.cl",
          "qnt_kernel_temp",
          len,
          ncp,
          p,
          df,
          lower_tail,
          log_p,
          out,
          verbose);
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
        "src/rt_kernel.cl", "rt_kernel_temp", {df, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dbinom_raw_kernel.cl",
        "dbinom_raw_kernel_temp",
        len,
        {&x, &n_size, &prob, &qprob},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dbinom_kernel.cl",
        "dbinom_kernel_temp",
        len,
        {&x, &size, &prob},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pbinom_kernel.cl",
        "pbinom_kernel",
        len,
        {&q, &size, &prob},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dnbinom_kernel.cl",
        "dnbinom_kernel_temp",
        len,
        {&x, &size, &prob},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pnbinom_kernel.cl",
        "pnbinom_kernel",
        len,
        {&q, &size, &prob},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qnbinom_kernel.cl",
        "qnbinom_kernel_temp",
        len,
        {&p, &size, &prob},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rnbinom_kernel.cl", "rnbinom_kernel_temp", {size, prob, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dnbinom_mu_kernel.cl",
        "dnbinom_mu_kernel_temp",
        len,
        {&x, &size, &mu},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pnbinom_mu_kernel.cl",
        "pnbinom_mu_kernel",
        len,
        {&q, &size, &mu},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rmultinom_kernel.cl", "rmultinom_kernel_temp", {size, prob, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dcauchy_kernel.cl",
        "dcauchy_kernel_temp",
        len,
        {&x, &location, &scale},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pcauchy_kernel.cl",
        "pcauchy_kernel",
        len,
        {&q, &location, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qcauchy_kernel.cl",
        "qcauchy_kernel_temp",
        len,
        {&p, &location, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rcauchy_kernel.cl", "rcauchy_kernel_temp", {location, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dexp_kernel.cl",
        "dexp_kernel_temp",
        len,
        {&x, &rate},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pexp_kernel.cl",
        "pexp_kernel",
        len,
        {&q, &rate},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qexp_kernel.cl",
        "qexp_kernel_temp",
        len,
        {&p, &rate},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dgeom_kernel.cl",
        "dgeom_kernel_temp",
        len,
        {&x, &prob},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pgeom_kernel.cl",
        "pgeom_kernel",
        len,
        {&q, &prob},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qgeom_kernel.cl",
        "qgeom_kernel_temp",
        len,
        {&p, &prob},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rgeom_kernel.cl", "rgeom_kernel_temp", {prob, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dhyper_kernel.cl",
        "dhyper_kernel_temp",
        len,
        {&x, &r, &b, &n1},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/phyper_kernel.cl",
        "phyper_kernel",
        len,
        {&q, &m, &n_black, &k},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qhyper_kernel.cl",
        "qhyper_kernel_temp",
        len,
        {&p, &r, &b, &n1},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rhyper_kernel.cl", "rhyper_kernel_temp", {r, b, n1, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qbinom_kernel.cl",
        "qbinom_kernel_temp",
        len,
        {&size, &prob, &p},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qpois_kernel.cl",
        "qpois_kernel_temp",
        len,
        {&p, &lambda},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dpois_raw_kernel.cl",
        "dpois_raw_kernel_temp",
        len,
        {&x, &lambda},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dpois_kernel.cl",
        "dpois_kernel_temp",
        len,
        {&x, &lambda},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/ppois_kernel.cl",
        "ppois_kernel",
        len,
        {&q, &lambda},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qnbinom_mu_kernel.cl",
        "qnbinom_mu_kernel_temp",
        len,
        {&p, &size, &mu},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rpois_kernel.cl", "rpois_kernel_temp", {0.0, 0.0, 0.0, lambda}, n_out, out, verbose);
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
        "src/rnbinom_mu_kernel.cl", "rnbinom_mu_kernel_temp", {size, mu, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dweibull_kernel.cl",
        "dweibull_kernel_temp",
        len,
        {&x, &shape, &scale},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pweibull_kernel.cl",
        "pweibull_kernel",
        len,
        {&q, &shape, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qweibull_kernel.cl",
        "qweibull_kernel_temp",
        len,
        {&p, &shape, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rweibull_kernel.cl", "rweibull_kernel_temp", {shape, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dlogis_kernel.cl",
        "dlogis_kernel_temp",
        len,
        {&x, &location, &scale},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/plogis_kernel.cl",
        "plogis_kernel",
        len,
        {&q, &location, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qlogis_kernel.cl",
        "qlogis_kernel_temp",
        len,
        {&p, &location, &scale},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rlogis_kernel.cl", "rlogis_kernel_temp", {location, scale, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dnbeta_kernel.cl",
        "dnbeta_kernel_temp",
        len,
        {&x, &shape1, &ncp, &shape2},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/ptukey_kernel.cl",
        "ptukey_kernel",
        len,
        {&q, &nmeans, &df, &nranges},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qtukey_kernel.cl",
        "qtukey_kernel_temp",
        len,
        {&p, &nmeans, &df, &nranges},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dwilcox_kernel.cl",
        "dwilcox_kernel_temp",
        len,
        {&x, &m, &n2},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/pwilcox_kernel.cl",
        "pwilcox_kernel",
        len,
        {&q, &m, &n2},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qwilcox_kernel.cl",
        "qwilcox_kernel_temp",
        len,
        {&p, &m, &n2},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    d_givelog_ndrange_kernel_temp_fill(
        "src/dsignrank_kernel.cl",
        "dsignrank_kernel_temp",
        len,
        {&x, &nsize},
        give_log,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/psignrank_kernel.cl",
        "psignrank_kernel",
        len,
        {&q, &nsize},
        lower_tail,
        log_p,
        out,
        verbose);
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
  if (!has_opencl() || len == 0) return out;

  try {
    pq_tail_ndrange_kernel_temp_fill(
        "src/qsignrank_kernel.cl",
        "qsignrank_kernel_temp",
        len,
        {&p, &nsize},
        lower_tail,
        log_p,
        out,
        verbose);
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
        "src/rsignrank_kernel.cl", "rsignrank_kernel_temp", {nsize, 0.0, 0.0, 0.0, 0.0}, n_out, out, verbose);
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
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/gammafn_kernel.cl",
      "gammafn_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgammafn_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/lgammafn_kernel.cl",
      "lgammafn_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector lgammafn_sign_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/lgammafn_sign_kernel.cl",
      "lgammafn_sign_kernel_temp",
      len,
      {&x},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/dpsifn_kernel.cl",
      "dpsifn_kernel_temp",
      len,
      {&x, &n_deriv, &kode, &m},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/psigamma_kernel.cl",
      "psigamma_kernel_temp",
      len,
      {&x, &deriv},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector digamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/digamma_kernel.cl",
      "digamma_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector trigamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/trigamma_kernel.cl",
      "trigamma_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector tetragamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/tetragamma_kernel.cl",
      "tetragamma_kernel_temp",
      len,
      {&x},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector pentagamma_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/pentagamma_kernel.cl",
      "pentagamma_kernel_temp",
      len,
      {&x},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/beta_special_kernel.cl",
      "beta_special_kernel_temp",
      len,
      {&a, &b},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/lbeta_special_kernel.cl",
      "lbeta_special_kernel_temp",
      len,
      {&a, &b},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/choose_special_kernel.cl",
      "choose_special_kernel_temp",
      len,
      {&n_val, &k},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/lchoose_special_kernel.cl",
      "lchoose_special_kernel_temp",
      len,
      {&n_val, &k},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_i_kernel.cl",
      "bessel_i_kernel_temp",
      len,
      {&x, &nu, &expo_scaled},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_j_kernel.cl",
      "bessel_j_kernel_temp",
      len,
      {&x, &nu},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_k_kernel.cl",
      "bessel_k_kernel_temp",
      len,
      {&x, &nu, &expo_scaled},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_y_kernel.cl",
      "bessel_y_kernel_temp",
      len,
      {&x, &nu},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_i_ex_kernel.cl",
      "bessel_i_ex_kernel_temp",
      len,
      {&x, &nu, &expo},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_j_ex_kernel.cl",
      "bessel_j_ex_kernel_temp",
      len,
      {&x, &nu},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_k_ex_kernel.cl",
      "bessel_k_ex_kernel_temp",
      len,
      {&x, &nu, &expo},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/bessel_y_ex_kernel.cl",
      "bessel_y_ex_kernel_temp",
      len,
      {&x, &nu},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/imax2_kernel.cl",
      "imax2_kernel_temp",
      len,
      {&x, &y},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/imin2_kernel.cl",
      "imin2_kernel_temp",
      len,
      {&x, &y},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/fmax2_kernel.cl",
      "fmax2_kernel_temp",
      len,
      {&x, &y},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/fmin2_kernel.cl",
      "fmin2_kernel_temp",
      len,
      {&x, &y},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector sign_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/sign_kernel.cl",
      "sign_kernel_temp",
      len,
      {&x},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/fprec_kernel.cl",
      "fprec_kernel_temp",
      len,
      {&x, &digits},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/fround_kernel.cl",
      "fround_kernel_temp",
      len,
      {&x, &digits},
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
  numeric_cols_ndrange_kernel_temp_fill(
      "src/fsign_kernel.cl",
      "fsign_kernel_temp",
      len,
      {&x, &y},
      out,
      verbose);
#endif
  return out;
}

Rcpp::NumericVector ftrunc_opencl(const Rcpp::NumericVector& x, bool verbose) {
  const int len = x.size();
  Rcpp::NumericVector out(len);
#ifdef USE_OPENCL
  if (!has_opencl() || len == 0) return out;
  numeric_cols_ndrange_kernel_temp_fill(
      "src/ftrunc_kernel.cl",
      "ftrunc_kernel_temp",
      len,
      {&x},
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
        "src/r_check_user_interrupt_kernel.cl", "r_check_user_interrupt_kernel_temp", {}, n_out, out, verbose);
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
        "src/r_check_stack_kernel.cl", "r_check_stack_kernel_temp", {}, n_out, out, verbose);
  } catch (const std::exception& e) {
    if (verbose) Rcpp::Rcout << e.what() << "\n";
    throw;
  }
#endif
  return out;
}

} // namespace nmathopencl

