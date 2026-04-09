library(testthat)
library(logrittr)

# helpers
small_df <- function() data.frame(
  x = 1:10, y = letters[1:10], z = LETTERS[1:10]
)

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

test_that("logrittr_options() returns defaults", {
  opts <- logrittr_options()
  expect_equal(opts$lang, "fr")
  expect_equal(opts$wrap_width, 52L)
})

test_that("logrittr_options() sets and restores", {
  old <- logrittr_options(lang = "en")
  expect_equal(logrittr_options()$lang, "en")
  do.call(logrittr_options, old)  # restore
  expect_equal(logrittr_options()$lang, "fr")
})

test_that("logrittr_options() rejects invalid lang", {
  expect_error(logrittr_options(lang = "de"), "`lang` must be one of")
})

test_that(".fmt_col_list truncates beyond max_cols", {
  logrittr_options(max_cols = 3L)
  on.exit(logrittr_options(max_cols = 5L))

  nms    <- c("a", "b", "c", "d", "e")
  result <- logrittr:::.fmt_col_list(nms, identity)
  expect_true(grepl("and 2 others", result))
  expect_false(grepl("\\bd\\b", result))
})

test_that(".fmt_col_list shows all when n <= max_cols", {
  logrittr_options(max_cols = 5L)
  nms    <- c("a", "b", "c")
  result <- logrittr:::.fmt_col_list(nms, identity)
  expect_false(grepl("other", result))
})
