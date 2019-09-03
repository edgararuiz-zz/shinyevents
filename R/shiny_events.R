# generic ---------------------------------------
#' Generic event implementation
#'
#' Customize the output or add a new target file (beyond CSV, log or Database).
#' To do that, override the `event()` function after assigning it to a variable.
#'
#' @param app The name of the app. Defaults to the name of the script's containing folder.
#'
#' @return An environment variable containing: a GUID, the name of the app, entry() function and event() function.
#'
#' @examples
#'
#' file_name <- tempfile(fileext = "txt")
#' tracker <- shiny_events("example-app")
#' tracker$event <- function(activity = "", value = "") {
#'   entry <- tracker$entry(activity = activity, value = value)
#'   cat(
#'     paste(
#'       entry$guid, entry$datetime, entry$app, entry$activity, entry$value, "\n, sep = "|"
#'     ),
#'     file = file_name, append = TRUE
#'   )
#' }
#' tracker$event("slider", "10")
#' readLines(file_name)
#' @export
shiny_events <- function(app = basename(getwd())) {
  se <- rlang::new_environment()
  se$guid <- uuid::UUIDgenerate()
  se$app <- app
  se$entry <- function(activity = "", value = "") {
    list(
      guid = se$guid,
      app = se$app,
      datetime = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
      activity = activity,
      value = value
    )
  }
  se$event <- function(activity = "", value = "") {
    stop("Recording mechanism has no been defined")
  }
  se
}

# csv -------------------------------------------
#' Record Shiny events on a CSV file
#'
#' @param app The name of the app. Defaults to the name of the script's containing folder.
#' @param filename CSV file name to use. Defaults to "shiny-events.csv"
#'
#' @return An environment variable containing: a GUID, the name of the app, entry() function and event() function.
#'
#' @examples
#'
#' file_name <- tempfile(fileext = ".csv")
#' tracker <- shiny_events_to_csv("example-app", file_name)
#' tracker$event("slider", 1)
#' read.csv(
#'   file_name,
#'   header = FALSE,
#'   col.names = c("guid", "app", "activity", "value", "datetime")
#' )
#' @export
shiny_events_to_csv <- function(app = basename(getwd()), filename = "shiny-events.csv") {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "") {
    entry <- se$entry(activity = activity, value = value)
    event_to_file(
      entry$guid, entry$app, entry$activity, entry$value, entry$datetime, 
      filename = filename, delimeter = ","
      )
  }
  se
}

event_to_file <- function(filename = NULL, delimeter = NULL, ...) {
  cat(
    paste0(paste(..., sep = delimeter), "\n"),
    file = filename,
    append = TRUE
  )
}

# log -------------------------------------------
#' Record Shiny events on a LOG file
#'
#' @param app The name of the app. Defaults to the name of the script's containing folder.
#' @param filename CSV file name to use. Defaults to "shiny-events.csv"
#'
#' @return An environment variable containing: a GUID, the name of the app, entry() function and event() function.
#'
#' @examples
#'
#' file_name <- tempfile(fileext = ".csv")
#' tracker <- shiny_events_to_log("example-app", file_name)
#' tracker$event("slider", 1)
#' # event() function allows the log type to be modified
#' tracker$event("records-returned", 0, type = "WARN")
#' readLines(file_name)
#' @export
shiny_events_to_log <- function(app = basename(getwd()), filename = "shiny-events.log") {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "", type = "INFO") {
    entry <- se$entry(activity = activity, value = value)
    event_to_file(
      entry$guid, entry$app, entry$activity, entry$value, entry$datetime, type, 
      filename = filename, delimeter = " "
      )
  }
  se
}

# dbi -------------------------------------------

#' Record Shiny events on a database
#'
#' Uses the `DBI` package to record events.  Here are a couple of highlights of how it works:
#' uses the `dbWriteTable()` function, this allows it to work on most databases `DBI` is
#' able to interact with, and the `append = TRUE` argument is used.  This allows the table to
#' be created if it doesn't exists yet, and only to add new records to the table, instead of overriding
#' its content
#'
#' @param app The name of the app. Defaults to the name of the script's containing folder.
#' @param table The name of the database table to use. Defautls to "shinyevents". If the table does not exist,
#' it will created. If it does exist, it will expect the fields to be: `guid`, `app`, `datetime`, `activity`, `value`
#' @param connection The name of the database connection
#' @return An environment variable containing: a GUID, the name of the app, entry() function and event() function.
#' @export
shiny_events_to_dbi <- function(app = basename(getwd()), table = "shinyevents", connection = NULL) {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "") {
    entry <- se$entry(activity = activity, value = value)
    event_to_dbi(connection = connection, 
                 table = table, entry = entry)
  }
  se
}

event_to_dbi <- function(connection, table, entry) {
  DBI::dbWriteTable(
    conn = connection, name = table, append = TRUE,
    value = as.data.frame(entry, stringsAsFactors = FALSE))
}
