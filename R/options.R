#' Get or set logrittr global options
#'
#' @description
#' Configure the behaviour of the `%>=%` pipe. Call with named arguments to
#' set options, or with no arguments to return current values.
#'
#' @param wrap_width Integer. Maximum width (in characters) of the step label
#'   before it wraps to the next line. Default: `32`.
#' @param big_mark Character. Thousands separator used when formatting counts.
#'   Default: `" "` (thin space). Use `","` for English convention or `""`
#'   to disable.
#' @param lang Character. Display language for the metrics line. One of
#'   `"en"` (default) or `"fr"`.
#' @param max_cols Integer. Maximum number of column names to display in the
#'   `added`/`dropped` lines. If there are more, the first `max_cols` are
#'   shown followed by `"and N others"`. Default: `5`. Use `Inf` to always
#'   show all columns.
#'
#' @return Invisibly returns the previous values of any option that was changed,
#'   as a named list. When called with no arguments, returns all current
#'   options as a named list (visibly).
#'
#' @examples
#' # French defaults
#' logrittr_options()
#'
#' # Switch to English, comma thousands separator, show up to 3 col names
#' logrittr_options(lang = "en", big_mark = ",", max_cols = 3)
#'
#' # Reset to defaults
#' logrittr_options(wrap_width = 52, big_mark = " ", lang = "fr", max_cols = 5)
#'
#' @export
logrittr_options <- function(wrap_width = NULL, big_mark = NULL,
                             lang = NULL, max_cols = NULL) {
  defaults <- list(
    logrittr.wrap_width = 32L,
    logrittr.big_mark   = "\u00a0",
    logrittr.lang       = "en",
    logrittr.max_cols   = 5L
  )
  
  if (is.null(wrap_width) && is.null(big_mark) && is.null(lang) && is.null(max_cols)) {
    current <- lapply(names(defaults), getOption)
    names(current) <- sub("logrittr\\.", "", names(defaults))
    current <- Map(function(cur, def) if (is.null(cur)) def else cur,
                   current, defaults)
    return(current)
  }
  
  if (!is.null(lang) && !lang %in% c("fr", "en")) {
    stop("`lang` must be one of \"fr\" or \"en\".", call. = FALSE)
  }
  if (!is.null(max_cols) && !is.numeric(max_cols) || isTRUE(max_cols < 1L)) {
    stop("`max_cols` must be a positive number or Inf.", call. = FALSE)
  }
  
  new_opts <- list()
  if (!is.null(wrap_width)) new_opts$logrittr.wrap_width <- as.integer(wrap_width)
  if (!is.null(big_mark))   new_opts$logrittr.big_mark   <- big_mark
  if (!is.null(lang))       new_opts$logrittr.lang       <- lang
  if (!is.null(max_cols))   new_opts$logrittr.max_cols   <- max_cols
  
  old <- lapply(names(new_opts), getOption)
  names(old) <- sub("logrittr\\.", "", names(new_opts))  # strip prefix so do.call works
  do.call(options, new_opts)
  invisible(old)
}


# Internal helpers -----------------------------------------------------------

.opt <- function(key, default) {
  v <- getOption(paste0("logrittr.", key))
  if (is.null(v)) default else v
}

.labels <- list(
  fr = list(rows = "lignes", cols = "cols"),
  en = list(rows = "rows",   cols = "cols")
)

.get_labels <- function() {
  lang <- .opt("lang", "fr")
  if (!lang %in% names(.labels)) lang <- "en"
  .labels[[lang]]
}
