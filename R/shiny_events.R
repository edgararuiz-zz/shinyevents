# generic ---------------------------------------
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
#' @export
shiny_events_to_csv <- function(app = basename(getwd()), filename = "shiny-events.csv") {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "") {
    entry <- se$entry(activity = activity, value = value)
    event_to_csv(
      sessionid = entry$guid,
      app =entry$app,
      activity = entry$activity,
      value = entry$value,
      time = entry$datetime,
      filename = filename
    )
  }
  se
}

event_to_csv <- function(sessionid, app, activity, 
                         value, time, filename){
  cat(
    paste0(
      sessionid, ",", app, ",", activity, ",",
      value, ",", time, "\n"
    ), 
    file = filename,
    append = TRUE
  )
}

# log -------------------------------------------
#' @export
shiny_events_to_log <- function(app = basename(getwd()), filename = "shiny-events.log") {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "", type = "INFO") {
    entry <- se$entry(activity = activity, value = value)
    event_to_log(
      sessionid = entry$guid,
      app =entry$app,
      activity = entry$activity,
      value = entry$value,
      time = entry$datetime,
      type = type,
      filename = filename
    )
  }
  se
}

event_to_log <- function(sessionid, app, activity, 
                         value, time, type, filename){
  cat(
    paste0(
      time, " ", type, " ", app, " ", sessionid, " ", 
      activity, " ", value, " ", "\n"
    ), 
    file = filename,
    append = TRUE
  )
}
