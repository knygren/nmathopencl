# Helper functions temporarily imported from the openclport package.
# These support write_kernel_dependency_index(), attach_kernel_dependency_tags(),
# and stage_kernel_dependency_sort().  They will migrate to openclport once that
# package is released and nmathopencl lists it as an Import.

# ---------------------------------------------------------------------------
# From openclport/R/shim_classify_to_shim.R
# ---------------------------------------------------------------------------

shim_classification_tag_pattern <- function() {
  paste0(
    "^\\s*//\\s*@(builtin|to_shim|to_shim_deterministic|to_shim_reason|",
    "to_shim_kind)(?=\\s|:)\\s*:?.*$"
  )
}

annotation_insert_after_shim_core_metadata <- function(lines) {
  core_tags <- c(
    "source_type", "source_origin",
    "includes", "all_includes", "used_includes",
    "depends", "provides", "used"
  )
  positions <- integer()
  for (tg in core_tags) {
    pat <- paste0("^\\s*//\\s*@", tg, "(?=\\s|:)\\s*:?.*$")
    hit <- grep(pat, lines, perl = TRUE)
    if (length(hit) > 0) {
      positions <- c(positions, max(hit))
    }
  }
  if (length(positions) > 0) {
    return(max(positions))
  }

  annotation_insert_position(lines)
}

# ---------------------------------------------------------------------------
# From openclport/R/port_create_kernel_library_from_source.R
# ---------------------------------------------------------------------------

escape_regex <- function(x) {
  gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
}

c_identifier_pattern <- function(symbol) {
  symbol <- as.character(symbol)
  if (!nzchar(symbol)) {
    return("$a") # matches nothing
  }
  paste0("(?<![A-Za-z0-9_])", escape_regex(symbol), "(?![A-Za-z0-9_])")
}

strip_c_strings <- function(lines) {
  gsub('"([^"\\\\]|\\\\.)*"', '""', lines, perl = TRUE)
}

strip_c_comments <- function(lines) {
  in_block <- FALSE
  vapply(lines, function(line) {
    out <- ""
    rest <- line
    repeat {
      if (isTRUE(in_block)) {
        end <- regexpr("\\*/", rest, perl = TRUE)[[1]]
        if (end < 0) {
          break
        }
        rest <- substring(rest, end + 2)
        in_block <<- FALSE
      } else {
        block_start <- regexpr("/\\*", rest, perl = TRUE)[[1]]
        line_start <- regexpr("//", rest, fixed = TRUE)[[1]]
        if (line_start >= 0 &&
            (block_start < 0 || line_start < block_start)) {
          out <- paste0(out, substring(rest, 1, line_start - 1))
          break
        }
        if (block_start >= 0) {
          out <- paste0(out, substring(rest, 1, block_start - 1))
          rest <- substring(rest, block_start + 2)
          in_block <<- TRUE
        } else {
          out <- paste0(out, rest)
          break
        }
      }
    }
    out
  }, character(1), USE.NAMES = FALSE)
}

function_definition_names_from_text <- function(text, include_static = FALSE) {
  defs <- function_definition_records_from_text(text)
  if (nrow(defs) == 0) {
    return(character())
  }
  storage <- defs$storage
  names <- defs$name
  keep <- !names %in% c("if", "for", "while", "switch", "return", "else")
  keep <- keep & names != "F77_SUB"
  if (!include_static) {
    keep <- keep & !grepl("\\bstatic\\b", storage)
  }
  names[keep]
}

function_definition_records_from_text <- function(text) {
  pattern <- paste0(
    "(?m)^\\s*((?:static\\s+|extern\\s+|inline\\s+|attribute_hidden\\s+)*)",
    "[A-Za-z_][A-Za-z0-9_\\s\\*]*\\s+",
    "([A-Za-z_][A-Za-z0-9_]*)\\s*\\([^;{}]*\\)\\s*\\{"
  )
  matches <- gregexpr(pattern, text, perl = TRUE)
  found <- regmatches(text, matches)[[1]]
  if (length(found) == 0 || identical(found, character(0))) {
    return(data.frame(storage = character(), name = character(),
                      stringsAsFactors = FALSE))
  }
  data.frame(
    storage = sub(pattern, "\\1", found, perl = TRUE),
    name = sub(pattern, "\\2", found, perl = TRUE),
    stringsAsFactors = FALSE
  )
}
