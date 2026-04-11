#' logrittr logger for lumberjack
#'
#' @description
#' An R6 logger that plugs into the lumberjack `%L>%` pipe and renders the
#' same console output as `%>=%`: row/column counts, signed deltas,
#' added/dropped column names, and approximate step timing.
#'
#' Requires the `R6` and `lumberjack` packages (both in `Suggests`).
#' If either is missing, the class is unavailable but the rest of logrittr
#' works normally.
#'
#' @section Timing:
#' lumberjack calls `$add()` after each step without providing a start time.
#' Elapsed time is measured as the interval between two consecutive `$add()`
#' calls. The first step always shows `NA ms`.
#'
#' @examples
#' \dontrun{
#' library(lumberjack)
#' library(dplyr)
#'
#' iris                                     %L>%
#'   start_log(log = logrittr_logger$new()) %L>%
#'   as_tibble()                            %L>%
#'   filter(Sepal.Length < 5)               %L>%
#'   mutate(rn = row_number())              %L>%
#'   group_by(Species)                      %L>%
#'   summarise(n = n_distinct(rn))          %L>%
#'   dump_log(stop = TRUE)
#' }
#'
#' @seealso [logrittr_options()], `%>=%`
#' @export
logrittr_logger <- if (requireNamespace("R6", quietly = TRUE) &&
                       requireNamespace("lumberjack", quietly = TRUE)) {
  
  R6::R6Class("logrittr_logger",
              
              public = list(
                
                #' @description Create a new `logrittr_logger`.
                initialize = function() {
                  private$t0 <- NULL
                },
                
                #' @description Called by lumberjack after each pipe step.
                #' @param meta List with elements `expr` and `src` (the step expression).
                #' @param input Data frame before the step.
                #' @param output Data frame after the step.
                add = function(meta, input, output) {
                  now     <- proc.time()["elapsed"]
                  elapsed <- if (!is.null(private$t0)) {
                    round((now - private$t0) * 1000, 1)
                  } else {
                    NA_real_
                  }
                  private$t0 <- now
                  
                  step_name  <- meta$src
                  before_r   <- if (is.data.frame(input))  nrow(input)   else NA
                  before_c   <- if (is.data.frame(input))  ncol(input)   else NA
                  before_nms <- if (is.data.frame(input))  names(input)  else character(0)
                  after_r    <- if (is.data.frame(output)) nrow(output)  else NA
                  after_c    <- if (is.data.frame(output)) ncol(output)  else NA
                  after_nms  <- if (is.data.frame(output)) names(output) else character(0)
                  
                  metrics <- .build_metrics(
                    after_r, after_c,
                    after_r - before_r,
                    after_c - before_c,
                    elapsed
                  )
                  
                  .log_step(step_name, depth = 0L, metrics)
                  .log_cols(before_nms, after_nms)
                },
                
                #' @description Called by `dump_log()`. No-op: output is already streamed
                #' to the console in real time.
                #' @param ... Ignored.
                dump = function(...) invisible(NULL)
              ),
              
              private = list(t0 = NULL)
  )
  
} else {
  NULL
}
