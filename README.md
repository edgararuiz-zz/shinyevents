
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyevents

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

  - [Installation](#installation)
  - [Usage](#usage)
  - [In a Shiny app](#in-a-shiny-app)
  - [More info](#more-info)
  - [CSV example](#csv-example)
  - [Database example](#database-example)
  - [Sample apps](#sample-apps)

The goal of `shinyevents` is to provide an easy way to log Shiny app
events. The logged information can be accumulated and later be used to
help improve the app’s performance and user’s experience.

## Installation

The development version of `shinyevents` is available on
[GitHub](https://github.com/):

``` r
# install.packages("remotes")
remotes::install_github("edgararuiz/shinyevents")
```

## Usage

`shinyevents` attempts to provide a simple way to track different Shiny
events by using two functions. The first function is one of three which
initialize the tracking:

  - `shiny_events_to_log()` - Saves the event data into a `.log` file
  - `shiny_events_to_csv()` - Saves the event data into a `.csv` file
  - `shiny_events_to_dbi()` - Saves the event data into a database, via
    the `DBI` package

Once the target for the event tracking is chosen, `shinyevents` is
initialized by assigning the function’s result to a variable:

``` r
library(shinyevents)

tracker <- shiny_events_to_log()
```

Once initialized, the second function to use, is one created inside the
assigned variable. The function is called: `event()`. Since selected
variable’s name was `tracker`, to access it we use `tracker$event()`. To
it we can pass two values, as arguments, those values are free-form
text, so the developer of the app can decide what to record:

``` r
tracker$event("example", "readme")
```

By default, the log file name is `shiny-events.log`. At this point, it
can be accessed in one of many ways. In this case we’ll just use
`readLines()`.

``` r
readLines("shiny-events.log")
#> [1] "2019-09-02 10:14:20 CDT INFO shinyevents b07e1e93-9674-4de0-9b20-39141427d19c example readme "
```

``` r
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")
```

``` r
readLines("shiny-events.log")
#> [1] "2019-09-02 10:14:20 CDT INFO shinyevents b07e1e93-9674-4de0-9b20-39141427d19c example readme "
#> [2] "2019-09-02 10:14:20 CDT INFO shinyevents b07e1e93-9674-4de0-9b20-39141427d19c start_app  "    
#> [3] "2019-09-02 10:14:20 CDT INFO shinyevents b07e1e93-9674-4de0-9b20-39141427d19c slider 3 "      
#> [4] "2019-09-02 10:14:20 CDT INFO shinyevents b07e1e93-9674-4de0-9b20-39141427d19c stop_app  "
```

## In a Shiny app

``` r
library(shiny)
library(shinyevents)
ui <- fluidPage(
    titlePanel("Old Faithful Geyser Data"),
    sidebarLayout(
        sidebarPanel(sliderInput("bins", "Bins:", 1, 50, 30)),
        mainPanel(plotOutput("distPlot"))
    ))
server <- function(input, output, session) {
    tracker <- shiny_events_to_log() # <- Initialize to log
    tracker$event("app_initiated") # <- Tracks start of app session
    observeEvent( # <- Track input using shiny::observeEvent()
      input$bins, 
      tracker$event("bin_slider", input$bins), # <- Pass the input's value to the event
      ignoreInit = TRUE) # <- Use ignoreInit to avoid logging the input's initial value
    session$onSessionEnded( # <- Track when the app closes using session$onSessionEnded
      function() tracker$event("close_app")) # <- Combine with a simple tracker entry
    output$distPlot <- renderPlot({
        tracker$event("plot_started", input$bins) # <- Tracks code start
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        tracker$event("plot_rendered", input$bins) # <- Tracks code completion
    })
}
shinyApp(ui, server)
```

``` r
readLines("shiny-events.log")
```

``` 
 [1] "2019-09-02 10:11:03 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f app_initiated  "  
 [2] "2019-09-02 10:11:03 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_started 30 " 
 [3] "2019-09-02 10:11:03 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_rendered 30 "
 [4] "2019-09-02 10:11:04 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f bin_slider 44 "   
 [5] "2019-09-02 10:11:05 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_started 44 " 
 [6] "2019-09-02 10:11:05 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_rendered 44 "
 [7] "2019-09-02 10:11:07 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_started 4 "  
 [8] "2019-09-02 10:11:07 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f plot_rendered 4 " 
 [9] "2019-09-02 10:11:07 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f bin_slider 4 "    
[10] "2019-09-02 10:11:08 CDT INFO shinyevents 56d89a96-9548-4713-b1e9-12c87e3de60f close_app  "   
```

## More info

``` r
tracker$app
#> [1] "shinyevents"
tracker$guid
#> [1] "b07e1e93-9674-4de0-9b20-39141427d19c"
```

``` r
tracker$entry()
#> $guid
#> [1] "b07e1e93-9674-4de0-9b20-39141427d19c"
#> 
#> $app
#> [1] "shinyevents"
#> 
#> $datetime
#> [1] "2019-09-02 10:14:20 CDT"
#> 
#> $activity
#> [1] ""
#> 
#> $value
#> [1] ""
```

## CSV example

``` r
tracker <- shiny_events_to_csv()
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")
```

``` r
read.csv(
  "shiny-events.csv",
  stringsAsFactors = FALSE,
  col.names = c("guid", "app", "activity", "value", "datetime")
)
#>                                   guid         app  activity value
#> 1 57848098-78a7-45e5-ac62-2307ee71789d shinyevents start_app    NA
#> 2 57848098-78a7-45e5-ac62-2307ee71789d shinyevents    slider     3
#> 3 57848098-78a7-45e5-ac62-2307ee71789d shinyevents  stop_app    NA
#>                  datetime
#> 1 2019-09-02 10:14:20 CDT
#> 2 2019-09-02 10:14:20 CDT
#> 3 2019-09-02 10:14:20 CDT
```

## Database example

``` r
library(DBI)
library(RSQLite)

con <- dbConnect(SQLite(), "example.db")
```

``` r
tracker <- shiny_events_to_dbi(table = "shinyevents", connection = con)
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")
```

``` r
dbGetQuery(con, "SELECT * FROM shinyevents")
#>                                   guid         app                datetime
#> 1 6a412c89-e292-4da1-9205-836888b35a5b shinyevents 2019-09-02 10:14:21 CDT
#> 2 6a412c89-e292-4da1-9205-836888b35a5b shinyevents 2019-09-02 10:14:21 CDT
#> 3 6a412c89-e292-4da1-9205-836888b35a5b shinyevents 2019-09-02 10:14:21 CDT
#>    activity value
#> 1 start_app      
#> 2    slider     3
#> 3  stop_app
```

``` r
dbDisconnect(con)
```

## Sample apps

The package includes several app examples. The example pictured below,
uses `shiny_events_to_dbi()` to record the events in a database, in this
case SQLite. It records when there are changes in each of the inputs, as
well as when the plot;s code starts and ends. There are entries for when
the app starts and is closed.

<img src="man/figures/example-app.png" align="center" width="600" />

<br/>

Run the following code in your R session to access the app:

``` r
shiny::runApp(
  system.file(
    "samples", "shinydashboard-db", 
    package = "shinyevents"
    ), 
  display.mode = "normal"
  )
```

### Additional samples

  - *Simple example* - An example using the “Old Faithful Geyser” app,
    shows the easiest way to include `shinyevents` in an app.
    
    ``` r
    shiny::runApp(
      system.file(
        "samples", "simple", 
        package = "shinyevents"
        ), 
      display.mode = "normal"
      )
    ```

  - *shinydashboard* - An example that looks the same as the
    `shinydashboard` example above, but it uses a CSV file to record the
    events instead of a database.
    
    ``` r
    shiny::runApp(
      system.file(
        "samples", "shinydashboard", 
        package = "shinyevents"
        ), 
      display.mode = "normal"
      )
    ```
