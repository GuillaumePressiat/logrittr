# Internal formatting helpers — not exported

.fmt_n <- function(n, width) {
  big_mark <- .opt("big_mark", "\u00a0")
  formatC(prettyNum(n, big.mark = big_mark), width = width, flag = " ")
}

.fmt_delta <- function(d, width) {
  s <- formatC(sprintf("%+d", d), width = -width, flag = "-")
  if (d < 0) cli::col_red(s) else if (d > 0) cli::col_green(s) else cli::col_grey(s)
}

.build_metrics <- function(after_r, after_c, dr, dc, elapsed) {
  lbl <- .get_labels()
  paste0(
    "  ", lbl$rows, ": ", .fmt_n(after_r, width = 9), " ", .fmt_delta(dr, width = 8),
    "  ", lbl$cols, ": ", .fmt_n(after_c, width = 4), " ", .fmt_delta(dc, width = 4),
    "  [", cli::col_grey(sprintf("%6.1f ms", elapsed)), "]"
  )
}

.log_step <- function(step_name, depth, metrics) {
  wrap_width <- max(.opt("wrap_width", 32L), cli::console_width() - 70)
  indent     <- strrep(" ", 2)
  prefix     <- if (depth == 0L) "" else paste0(strrep("  ", depth), "> ")
  label      <- paste0(prefix, step_name)
  lines      <- stringr::str_split(stringr::str_wrap(label, width = wrap_width), "\n")[[1]]

  cli::cli_alert_info(paste0(
    cli::col_grey(formatC(lines[1], width = -wrap_width, flag = "-")),
    metrics
  ))
  if (length(lines) > 1) {
    for (l in lines[-1]) cli::cli_bullets(c(" " = cli::col_grey(paste0(indent, l))))
  }
}

.fmt_col_list <- function(nms, color_fn) {
  max_cols <- .opt("max_cols", 5L)
  n        <- length(nms)
  
  if (n <= max_cols) {
    paste(color_fn(nms), collapse = cli::col_grey(", "))
  } else {
    shown    <- nms[seq_len(max_cols)]
    n_others <- n - max_cols
    lang     <- .opt("lang", "en")
    others   <- if (lang == "fr") {
      cli::col_grey(sprintf("et %d autre%s", n_others, if (n_others > 1) "s" else ""))
    } else {
      cli::col_grey(sprintf("and %d other%s", n_others, if (n_others > 1) "s" else ""))
    }
    paste(c(paste(color_fn(shown), collapse = cli::col_grey(", ")), others),
          collapse = cli::col_grey(", "))
  }
}

.log_cols <- function(before_names, after_names, verbose = TRUE) {
  dropped <- setdiff(before_names, after_names)
  if (length(dropped) > 0 && verbose) {
    cli::cli_bullets(c(" " = paste0(
      cli::col_grey("dropped: "),
      .fmt_col_list(dropped, cli::col_magenta)
    )))
  }

  added <- setdiff(after_names, before_names)
  if (length(added) > 0 && verbose) {
    cli::cli_bullets(c(" " = paste0(
      cli::col_grey("added: "),
      .fmt_col_list(added, cli::col_blue)
    )))
  }
  
  return(list(dropped = dropped, added = added))
}


