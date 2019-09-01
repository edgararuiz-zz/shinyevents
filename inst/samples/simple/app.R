library(shiny)
library(shinyevents)

ui <- fluidPage(
    titlePanel("Old Faithful Geyser Data"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins", "Number of bins:",
                        min = 1, max = 50, 
                        value = 30)
        ),
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

server <- function(input, output, session) {
    ## Initialized a new shinyevents variable, we'll call it `tracker`
    tracker <- shiny_events_to_log()
    ## A simple entry that logs when the app is initially started
    tracker$event("app_initiated")
    ## Changes to inputs can be tracked using shiny::observeEvent()
    observeEvent(input$bins, tracker$event("bin_slider", input$bins))
    ## session$onSessionEnded allows to track when the session was ended
    session$onSessionEnded(function() tracker$event("close_app"))
    
    output$distPlot <- renderPlot({
        ## Tracks when the output's code was started
        tracker$event("plot_started", input$bins)
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        ## Tracks when the code was completed
        tracker$event("plot_rendered", input$bins)
    })
}

shinyApp(ui, server)
