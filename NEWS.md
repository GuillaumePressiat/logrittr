# logrittr (development version)

# logrittr 0.1.0

First release (proof of concept).

* `%>=%` : logging pipe operator: row counts, column counts, added/dropped
  columns, and step timing at each stage of a dplyr pipeline.
* `logrittr_options()` : global options for `wrap_width`, `big_mark`, `lang`
  (`"fr"` / `"en"`), and `max_cols`.
* Nested pipelines automatically detected and displayed with increasing
  indentation via `options(.LPipe_depth)`.
* Added `logrittr_logger`: an R6 logger for use with the `lumberjack` package.
