# Insert // @depends_nmath: <stem> into inst/cl/src kernels that lack it.
# Stems are validated against inst/cl/nmath/kernel_dependency_index.rds.
#
# Run from package root:
#   Rscript tools/seed_src_kernel_depends_nmath.R
# Or: Rscript tools/seed_src_kernel_depends_nmath.R /path/to/nmathopencl

resolve_pkg_dir <- function() {
  argv <- suppressWarnings(commandArgs(trailingOnly = TRUE))
  argv <- argv[nzchar(argv)]
  if (length(argv) >= 1L) {
    return(normalizePath(argv[[1L]], winslash = "/", mustWork = TRUE))
  }
  args <- commandArgs(trailingOnly = FALSE)
  farg <- grep("^--file=", args, value = TRUE)
  if (length(farg) == 1L) {
    tool_path <- sub("^--file=", "", farg[1L])
    tool_path <- normalizePath(tool_path, winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(tool_path), ".."), winslash = "/", mustWork = TRUE))
  }
  wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  if (basename(wd) == "tools") {
    return(normalizePath(file.path(wd, ".."), winslash = "/", mustWork = TRUE))
  }
  wd
}

pkg_dir <- resolve_pkg_dir()
if (!file.exists(file.path(pkg_dir, "DESCRIPTION"))) {
  stop("Not an R package root: ", pkg_dir, call. = FALSE)
}

src_dir <- file.path(pkg_dir, "inst/cl/src")
idx <- readRDS(file.path(pkg_dir, "inst/cl/nmath/kernel_dependency_index.rds"))
nms <- names(idx[["all_depends"]])

# Kernel basename (without _kernel.cl) -> nmath index stem or "none".
# Default: basename matches a stem; otherwise _raw suffix is stripped once.
stem_override <- c(
  bessel_i_ex = "bessel_i",
  bessel_j_ex = "bessel_j",
  bessel_k_ex = "bessel_k",
  bessel_y_ex = "bessel_y",
  beta_special = "beta",
  choose_special = "choose",
  dbinom_raw = "dbinom",
  digamma = "polygamma",
  dnbinom_mu = "dnbinom",
  dpois_raw = "dpois",
  dpsifn = "polygamma",
  dsignrank = "signrank",
  dwilcox = "wilcox",
  exp_rand = "sexp",
  gammafn = "gamma",
  lbeta_special = "lbeta",
  lchoose_special = "choose",
  lgamma1p = "pgamma_utils",
  lgammafn = "lgamma",
  log1mexp = "plogis",
  log1pexp = "plogis",
  log1pmx = "pgamma_utils",
  logspace_add = "pgamma",
  logspace_sub = "pgamma",
  logspace_sum = "pgamma",
  norm_rand = "snorm",
  pentagamma = "polygamma",
  pnbinom_mu = "pnbinom",
  pow1p = "dbinom",
  psigamma = "polygamma",
  psignrank = "signrank",
  pwilcox = "wilcox",
  qsignrank = "signrank",
  qwilcox = "wilcox",
  r_check_stack = "none",
  r_pow = "none",
  r_pow_di = "none",
  r_unif_index = "sunif",
  rnbinom_mu = "rnbinom",
  rsignrank = "signrank",
  rwilcox = "wilcox",
  tetragamma = "polygamma",
  trigamma = "polygamma",
  unif_rand = "sunif"
)

resolve_stem <- function(base) {
  if (base %in% names(stem_override)) {
    return(unname(stem_override[[base]]))
  }
  if (base %in% nms) {
    return(base)
  }
  br <- sub("_raw$", "", base)
  if (br %in% nms) {
    return(br)
  }
  stop("No stem for kernel base '", base, "'. Add to stem_override in this script.",
       call. = FALSE)
}

depends_pattern <- "^\\s*//\\s*@depends_nmath(?=\\s|:)"

ff <- list.files(src_dir, pattern = "_kernel[.]cl$", full.names = TRUE)
if (length(ff) == 0L) {
  stop("No *_kernel.cl files under ", src_dir, call. = FALSE)
}

n_new <- 0L
for (path in ff) {
  lines <- readLines(path, warn = FALSE)
  if (any(grepl(depends_pattern, lines, perl = TRUE))) {
    next
  }
  base <- sub("_kernel[.]cl$", "", basename(path))
  stem <- resolve_stem(base)

  ins <- grep("^\\s*#pragma\\s+OPENCL", lines)[1L]
  if (is.na(ins)) {
    ins <- 1L
  }

  if (identical(stem, "none")) {
    block <- c("// @depends_nmath: none", "")
  } else {
    block <- c("// @library_deps: nmath", paste0("// @depends_nmath: ", stem), "")
  }
  out <- append(lines, block, after = ins - 1L)
  writeLines(out, path, useBytes = TRUE)
  message("added @depends_nmath -> ", stem, " : ", basename(path))
  n_new <- n_new + 1L
}

message("seed_src_kernel_depends_nmath: inserted tags on ", n_new, " file(s).")
