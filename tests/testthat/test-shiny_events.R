context("shiny_events()")
test_that("shiny_events()", {
  tracker <- shiny_events("example-app")
  te <- tracker$entry("activity", "value")
  expect_equal(tracker$app, "example-app")
  expect_equal(nchar(tracker$guid), 36)
  expect_equal(tracker$guid, te$guid)
  expect_equal(tracker$app, te$app)
  expect_equal(nchar(te$datetime), 23)
  expect_equal(te$activity, "activity")
  expect_equal(te$value, "value")
  expect_error(tracker$event(), "Recording mechanism")
})

context("shiny_events_to_csv()")
test_that("shiny_events_to_csv()", {
  file_name <- tempfile(fileext = ".csv")
  tracker <- shiny_events_to_csv("example-app", file_name)
  tracker$event("slider", 1)
  log_file <- read.csv(
    file_name,
    header = FALSE,
    col.names = c("guid", "app", "activity", "value", "datetime")
  )
  expect_is(log_file, "data.frame")
  expect_equal(nrow(log_file), 1)
})

context("shiny_events_to_log()")
test_that("shiny_events_to_log()", {
  file_name <- tempfile(fileext = ".txt")
  tracker <- shiny_events_to_log("example-app", file_name)
  tracker$event("slider", 1)
  log_file <- readLines(file_name)
  expect_is(log_file, "character")
  expect_length(log_file, 1)
})

context("shiny_events_to_dbi()")
test_that("shiny_events_to_dbi()", {
  tracker <- shiny_events_to_dbi()
  expect_is(tracker$entry(), "list")
})
