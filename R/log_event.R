#' @export
shiny_events <- function(app = basename(getwd())) {
  se <- rlang::new_environment()
  se$guid <- uuid::UUIDgenerate()
  se$app <- app
  se$entry <- function(activity = "", value = "") {
    list(
      guid = se$guid,
      app = se$app,
      datetime = as.character(Sys.time()),
      activity = activity,
      value = value
    )
  }
  se$event <- function(activity = "", value = "") {
    stop("Recording mechanism has no been defined")
  }
  se
}

#' @export
shiny_events_to_file <- function(app = basename(getwd())) {
  se <- shiny_events(app = app)
  se$event <- function(activity = "", value = "") {
    entry <- se$entry(activity = activity, value = value)
    event_to_file(
      sessionid = entry$guid,
      app =entry$app,
      activity = entry$activity,
      value = entry$value,
      time = entry$datetime
    )
  }
  se
}

event_to_file <- function(sessionid = NULL, app = NULL, 
                          activity = NULL, value = NULL, 
                          time = NULL, filename = "shiny-log.csv"){
  cat(paste0(
    sessionid, ",", 
    app, ",",
    activity, ",",
    value, ",",
    time,
    "\n"
  ), 
  file = filename,
  append = TRUE)
}

