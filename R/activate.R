#' Activate logrittr logging on the %>% pipe
#'
#' @description
#' Replaces `%>%` in the global environment with `%>=%` so that existing
#' pipelines using `%>%` are automatically logged without any code change.
#'
#' Call [logrittr_deactivate()] to restore the original `%>%` behaviour.
#'
#' @return Invisibly returns the previous definition of `%>%` in the global
#'   environment (or `NULL` if none existed).
#'
#' @examples
#' \dontrun{
#' library(logrittr)
#' library(dplyr)
#'
#' logrittr_activate()
#'
#' iris %>%
#'   filter(Sepal.Length < 5) %>%
#'   group_by(Species) %>%
#'   summarise(n = n())
#'
#' logrittr_deactivate()
#' }
#'
#' @seealso [logrittr_deactivate()], [logrittr_hook()]
#' @export
logrittr_activate <- function() {
  prev <- if (exists("%>%", envir = globalenv(), inherits = FALSE)) {
    get("%>%", envir = globalenv())
  } else {
    NULL
  }
  assign("%>%", `%>=%`, envir = globalenv())
  cli::cli_alert_success(
    "logrittr activated: {.code %>%} now logs like {.code %>=%}"
  )
  invisible(prev)
}

#' Deactivate logrittr logging on the %>% pipe
#'
#' @description
#' Restores `%>%` in the global environment to its original definition
#' (magrittr's pipe if available, otherwise removes the binding).
#'
#' @return Invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' logrittr_activate()
#' # ... work ...
#' logrittr_deactivate()
#' }
#'
#' @seealso [logrittr_activate()], [logrittr_hook()]
#' @export
logrittr_deactivate <- function() {
  if (requireNamespace("magrittr", quietly = TRUE)) {
    assign("%>%", magrittr::`%>%`, envir = globalenv())
    cli::cli_alert_info(
      "logrittr deactivated: {.code %>%} restored to magrittr"
    )
  } else {
    if (exists("%>%", envir = globalenv(), inherits = FALSE)) {
      rm("%>%", envir = globalenv())
    }
    cli::cli_alert_info(
      "logrittr deactivated: {.code %>%} removed from global environment"
    )
  }
  invisible(NULL)
}


#' knitr source hook for pipe logging
#'
#' @description
#' Registers a knitr source hook that enables logrittr logging in R Markdown
#' and Quarto documents, with no change to pipeline code.
#'
#' - `"native"` (default): rewrites `|>` to `%>=%` in chunks where the chunk
#'   option `logrittr = TRUE` is set.
#' - `"magrittr"`: calls [logrittr_activate()] so `%>%` logs globally.
#' - `"both"`: does both of the above.
#'
#' @param pipe Character. Which pipe(s) to intercept. One of `"native"`,
#'   `"magrittr"`, or `"both"`. Default: `"native"`.
#'
#' @return Invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' # In your setup chunk:
#' library(logrittr)
#'
#' knitr::opts_chunk$set(
#' collapse  = TRUE,
#' comment   = "#>",
#' message   = TRUE   # needed to show logrittr output (uses message())
#' )
#' 
#' # For |> pipes (opt-in per chunk with logrittr = TRUE):
#' logrittr_hook()
#'
#' # For %>% pipes (global):
#' logrittr_hook("magrittr")
#'
#' # For both:
#' logrittr_hook("both")
#'
#' # Then in any chunk you want logged (native pipe):
#' # ```{r, logrittr = TRUE}
#' # iris |>
#' #   filter(Sepal.Length < 5) |>
#' #   group_by(Species) |>
#' #   summarise(n = n())
#' # ```
#' }
#'
#' @seealso [logrittr_activate()], [logrittr_deactivate()]
#' @export
logrittr_hook <- function(pipe = c("native", "magrittr", "both")) {
  pipe <- match.arg(pipe)
  
  if (pipe %in% c("magrittr", "both")) {
    logrittr_activate()
  }
  
  if (pipe %in% c("native", "both")) {
  # opts_hooks modifies options$code BEFORE evaluation: this is the key
  # source hook only affects display, not execution
  knitr::opts_hooks$set(logrittr = function(options) {
    if (isTRUE(options$logrittr)) {
      options$code <- gsub("[|][>]", "%>=%", options$code)
    }
    options
  })
    
    msg <- switch(pipe,
                  native = "logrittr knitr hook registered for {.code |>}: use {.code logrittr = TRUE} per chunk",
                  both   = "logrittr knitr hook registered for {.code |>} and {.code %>%}"
    )
    cli::cli_alert_success(msg)
  }
  
  if (pipe == "magrittr") {
    # message already printed by logrittr_activate()
  }
  
  invisible(NULL)
}
