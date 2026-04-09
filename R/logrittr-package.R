#' logrittr: A verbose pipe operator for dplyr pipelines
#'
#' @description
#' logrittr provides the `%>=%` operator — a logging pipe inspired by the
#' SAS DATA step log. At each step it reports: row count (before → after),
#' column count (before → after), added/dropped column names, and elapsed time.
#'
#' Nested pipelines are automatically indented. Display is configurable via
#' [logrittr_options()].
#'
#' @section Main function:
#' - `%>=%`: the logging pipe operator
#'
#' @section Options:
#' - [logrittr_options()]: get or set wrap width, thousands separator, language
#'
#' @keywords internal
"_PACKAGE"

#' @import cli
#' @import stringr
NULL
