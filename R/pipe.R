#' Logging pipe operator
#'
#' @description
#' A drop-in replacement for `%>%` that logs row counts, column counts,
#' added/dropped column names, and step timing at each stage of a dplyr / tidyr pipeline.
#' Inspired by the SAS DATA step log and mostly for educational context in R.
#'
#' Nested pipelines (e.g. inside a `semi_join()` or `filter()` argument) are
#' automatically detected and displayed with increasing indentation, so the
#' main pipeline and its sub-pipelines are visually distinct.
#'
#' @param lhs A data frame (or tibble) passed as the left-hand side.
#' @param rhs An unevaluated dplyr-style function call.
#'
#' @return The result of applying `rhs` to `lhs`, invisibly from the logging
#'   perspective — the value is returned normally so pipelines compose as
#'   expected.
#'
#' @details
#' Depth tracking uses `options(.LPipe_depth)` which is incremented around the
#' evaluation of `rhs` only, ensuring that the steps of the *main* pipeline
#' always log at depth 0 and nested `%>=%` calls at depth 1, 2, etc.
#'
#' Display options (`wrap_width`, `big_mark`, `lang`) are controlled via
#' [logrittr_options()].
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' logrittr_options(lang = "en", big_mark = ",", wrap_width = 30)
#' 
#' iris %>=%
#'   as_tibble() %>=%
#'   filter(Sepal.Length < 5) %>=%
#'   mutate(rn = row_number()) %>=%
#'   group_by(Species) %>=%
#'   summarise(n = n_distinct(rn))
#' }
#'
#' 
#' @seealso [logrittr_options()]
#' @rdname pipe_log
#' @export
`%>=%` <- function(lhs, rhs) {
  rhs_expr <- substitute(rhs)
  step_name <- paste(deparse(rhs_expr), collapse = " ")

  # Capture lhs name BEFORE force() evaluates it
  lhs_name <- paste(deparse(substitute(lhs)), collapse = " ")

  # Evaluate lhs first so depth is still at the parent level
  force(lhs)
  before_r     <- if (is.data.frame(lhs)) nrow(lhs)   else NA
  before_c     <- if (is.data.frame(lhs)) ncol(lhs)   else NA
  before_names <- if (is.data.frame(lhs)) names(lhs)  else character(0)

  # Read depth AFTER lhs is resolved, BEFORE evaluating rhs
  depth     <- getOption(".LPipe_depth", default = 0L)
  
  # Print pipeline header on the first step of a main pipeline
  if (depth == 0L && !isTRUE(attr(lhs, ".logrittr_pipe"))) {
    .log_header(lhs_name, before_r, before_c)
  }
  
  full_call <- as.call(c(list(rhs_expr[[1]]), list(lhs), as.list(rhs_expr[-1])))
  t0        <- proc.time()["elapsed"]

  # Increment only around rhs evaluation so sub-pipelines see depth + 1
  options(.LPipe_depth = depth + 1L)
  result <- tryCatch(
    eval(full_call, envir = parent.frame()),
    finally = options(.LPipe_depth = depth)
  )

  after_r    <- if (is.data.frame(result)) nrow(result)   else NA
  after_c    <- if (is.data.frame(result)) ncol(result)   else NA
  after_names <- if (is.data.frame(result)) names(result) else character(0)
  elapsed    <- round((proc.time()["elapsed"] - t0) * 1000, 1)

  metrics <- .build_metrics(
    after_r, after_c,
    after_r - before_r,
    after_c - before_c,
    elapsed
  )

  .log_step(step_name, depth, metrics)
  .log_cols(before_names, after_names)

  # Mark result so the next step knows it's mid-pipeline
  if (is.data.frame(result)) attr(result, ".logrittr_pipe") <- TRUE
  result
}

#' Pipe with logging
#'
#' @name pipe_log
#' @rdname pipe_log
NULL

