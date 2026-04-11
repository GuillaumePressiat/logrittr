library(testthat)
library(logrittr)

# helpers
small_df <- function() data.frame(
  x = 1:10, y = letters[1:10], z = LETTERS[1:10]
)

reset_opts <- function() {
  logrittr_options(wrap_width = 32L, big_mark = "\u00a0", lang = "en", max_cols = 5L)
}

# -- pipe -----------------------------------------------------------------

test_that("%>=% returns correct result", {
  result <- small_df() %>=% subset(x > 5)
  expect_equal(nrow(result), 5L)
  expect_equal(ncol(result), 3L)
})

test_that("%>=% works with column addition", {
  result <- small_df() %>=% transform(w = x * 2)
  expect_equal(ncol(result), 4L)
  expect_true("w" %in% names(result))
})

test_that("%>=% works with column removal", {
  result <- small_df() %>=% subset(select = -z)
  expect_equal(ncol(result), 2L)
  expect_false("z" %in% names(result))
})

test_that("%>=% resets .LPipe_depth after execution", {
  small_df() %>=% subset(x > 5)
  expect_equal(getOption(".LPipe_depth", 0L), 0L)
})

test_that("%>=% resets .LPipe_depth after error", {
  expect_error(small_df() %>=% stop("oops"))
  expect_equal(getOption(".LPipe_depth", 0L), 0L)
})

# -- options --------------------------------------------------------------

test_that("logrittr_options() returns defaults", {
  reset_opts()
  opts <- logrittr_options()
  expect_equal(opts$lang, "en")
  expect_equal(opts$wrap_width, 32L)
  expect_equal(opts$max_cols, 5L)
})

test_that("logrittr_options() sets and restores via returned value", {
  reset_opts()
  old <- logrittr_options(lang = "fr")
  on.exit(do.call(logrittr_options, old))
  
  expect_equal(logrittr_options()$lang, "fr")
  do.call(logrittr_options, old)
  expect_equal(logrittr_options()$lang, "en")
})

test_that("logrittr_options() rejects invalid lang", {
  expect_error(logrittr_options(lang = "de"), "`lang` must be one of")
})

test_that(".fmt_col_list truncates beyond max_cols", {
  old_val <- getOption("logrittr.max_cols")
  options(logrittr.max_cols = 3L)
  on.exit(options(logrittr.max_cols = old_val))
  
  nms    <- c("a", "b", "c", "d", "e")
  result <- logrittr:::.fmt_col_list(nms, identity)
  expect_true(grepl("and 2 others", result))
  expect_false(grepl("\\bd\\b", result))
})

test_that(".fmt_col_list shows all when n <= max_cols", {
  reset_opts()
  nms    <- c("a", "b", "c")
  result <- logrittr:::.fmt_col_list(nms, identity)
  expect_false(grepl("other", result))
})

# -- lumberjack logger ----------------------------------------------------

test_that("logrittr_logger is available when R6 is installed", {
  skip_if_not_installed("R6")
  expect_false(is.null(logrittr_logger))
  expect_true(R6::is.R6Class(logrittr_logger))
})

test_that("logrittr_logger$add() runs without error", {
  skip_if_not_installed("R6")
  logger <- logrittr_logger$new()
  meta   <- list(expr = quote(filter(x > 1)), src = "filter(x > 1)")
  input  <- data.frame(x = 1:10)
  output <- data.frame(x = 5:10)
  expect_no_error(logger$add(meta, input, output))
})

