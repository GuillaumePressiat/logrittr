# logrittr (development version)

* Added `logrittr_activate()` / `logrittr_deactivate()`: replace `%>%` in the
  global environment with `%>=%` (and restore it) so existing pipelines are
  logged without any code change. Only for `%>%` pipe.
* Added `logrittr_hook()`: knitr source hook that rewrites `|>` or `%>%` to `%>=%`
  in chunks where `logrittr = TRUE` is set, enabling native-pipe logging in
  R Markdown and Quarto documents.


# logrittr 0.1.0

First release (proof of concept).

* `%>=%` : logging pipe operator: row counts, column counts, added/dropped
  columns, and step timing at each stage of a dplyr pipeline.
* `logrittr_options()` : global options for `wrap_width`, `big_mark`, `lang`
  (`"fr"` / `"en"`), and `max_cols`.
* Nested pipelines automatically detected and displayed with increasing
  indentation via `options(.LPipe_depth)`.
* Added `logrittr_logger`: an R6 logger for use with the `lumberjack` package.
