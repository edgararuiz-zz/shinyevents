session_setup <- rlang::new_environment()
session_setup$init <- FALSE
session_setup$backend <- NULL
session_setup$guid <- NULL
session_setup$app <- NULL

#' @export
shinyevents_init <- function(app, backend = c("file", "database", "plumber")) {
  session_setup$guid <- uuid::UUIDgenerate()
  session_setup$backend <- backend
  session_setup$app <- app
  session_setup$init <- TRUE
}

get_session_uuid <- function() session_setup$guid
get_session_backend <- function() session_setup$backend
session_init <- function() session_setup$init

#' @export
get_session_setup <- function() session_setup

#' @export
shinyevents_log <- function(activity, value) {
  
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

