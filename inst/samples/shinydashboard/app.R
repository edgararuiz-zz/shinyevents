## app.R ##
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(
        fluidRow(
            box(title = "Box title", "Box content"),
            box(status = "warning", "Box content")
        ),
        
        fluidRow(
            box(
                title = "Title 1", width = 4, solidHeader = TRUE, status = "primary",
                "Box content"
            ),
            box(
                title = "Title 2", width = 4, solidHeader = TRUE,
                "Box content"
            ),
            box(
                title = "Title 1", width = 4, solidHeader = TRUE, status = "warning",
                "Box content"
            )
        ),
        
        fluidRow(
            box(
                width = 4, background = "black",
                "A box with a solid black background"
            ),
            box(
                title = "Title 5", width = 4, background = "light-blue",
                "A box with a solid light-blue background"
            ),
            box(
                title = "Title 6",width = 4, background = "maroon",
                "A box with a solid maroon background"
            )
        )
    )
)

server <- function(input, output, session) {
    ## Initialized a new shinyevents variable, we'll call it `tracker`
    tracker <- shiny_events_to_csv()
    ## A simple entry that logs when the app is initially started
    tracker$event("app_initiated")
    ## Changes to inputs can be tracked using shiny::observeEvent()
    #observeEvent(input$bins, tracker$event("bin_slider", input$bins))
    ## session$onSessionEnded allows to track when the session was ended
    session$onSessionEnded(function() tracker$event("close_app"))
    
}

shinyApp(ui, server)
