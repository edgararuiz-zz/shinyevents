
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyevents

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

  - [Installation](#installation)
  - [Usage](#usage)
  - [In a Shiny app](#in-a-shiny-app)
  - [More info](#further-info)
      - [Custom event](#custom-event)
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
#> [1] "2019-09-02 14:29:37 CDT INFO shinyevents d6fd3a63-2047-4453-bfad-1718e2c07c6f example readme "
```

A Globally Unique Identifier, or GUID, is created by
`shiny_events_to_log()`. Every event entry for that session will contain
the same GUID. This allows us to know what activity was part of which
app’s user session.

``` r
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")
```

``` r
readLines("shiny-events.log")
#> [1] "2019-09-02 14:29:37 CDT INFO shinyevents d6fd3a63-2047-4453-bfad-1718e2c07c6f example readme "
#> [2] "2019-09-02 14:29:37 CDT INFO shinyevents d6fd3a63-2047-4453-bfad-1718e2c07c6f start_app  "    
#> [3] "2019-09-02 14:29:37 CDT INFO shinyevents d6fd3a63-2047-4453-bfad-1718e2c07c6f slider 3 "      
#> [4] "2019-09-02 14:29:37 CDT INFO shinyevents d6fd3a63-2047-4453-bfad-1718e2c07c6f stop_app  "
```

## In a Shiny app

Here is the code for a sample app that tracks several different events:

  - App’s session begins
  - Slider is changed, and its current value
  - Beginning of the plot’s output processing
  - Completion of the plot’s output processing
  - App’s session closes

Feel free to copy and run this code in your R session. There are several
comments inside the code to further clarify the purpose of the tracking
related activity.

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
    tracker <- shiny_events_to_log() # <- Initializes as log file
    tracker$event("app_initiated") # <- Tracks start of app session
    observeEvent( # <- Track input using shiny::observeEvent()
      input$bins, 
      tracker$event("bin_slider", input$bins), # <- Pass the input's value to the event
      ignoreInit = TRUE) # <- ignoreInit avoids logging the input's initial value
    session$onSessionEnded( # <- Track when the app closes using session$onSessionEnded
      function() tracker$event("close_app")) # <- Combine with a simple event entry
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

After playing a bit with the slider, the app can be closed. This
activity was recorded in a new file, called `shiny-events.log`. If you
tried the app code above, use the `readLines()` code below to see the
resulting
entries.

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

## Further info

Some additional information is exposed by the variable assigned to the
Shiny event function. These are made available to allow developers to
use them in other functions, or to create a custom target for the event
tracking. Two of these are:

  - The app’s name
  - The session’s GUID

<!-- end list -->

``` r
tracker$app
#> [1] "shinyevents"
tracker$guid
#> [1] "d6fd3a63-2047-4453-bfad-1718e2c07c6f"
```

The `entry()` function returns a `list` object. The list contains the
session information, and the date/time of the entry. This is the base
function that the `shiny_events_to_log()`, `shiny_events_to_csv()` and
`shiny_events_to_dbi()` use.

``` r
tracker$entry()
#> $guid
#> [1] "d6fd3a63-2047-4453-bfad-1718e2c07c6f"
#> 
#> $app
#> [1] "shinyevents"
#> 
#> $datetime
#> [1] "2019-09-02 14:29:37 CDT"
#> 
#> $activity
#> [1] ""
#> 
#> $value
#> [1] ""
```

### Custom event

It is possible to customize the output or add a new target file (beyond
CSV, log or Database). To do that, override the `event()` function after
assigning it to a variable. For example:

``` r
tracker <- shiny_events()
tracker$event <- function(activity = "", value = "") { 
  entry <- se$entry(activity = activity, value = value)
  "[Your code's event recording. Uses data from `entry`]"
}
tracker$event("example", "readme")
```

## CSV example

Initialize a new CSV log with `shiny_events_to_csv()`.

``` r
tracker <- shiny_events_to_csv()
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")
```

To avoid file locks, `shiny_events_to_csv()` uses the `cat()` function
inside its code. It also means that the table will not have headers, so
they have to be defined at read time:

``` r
read.csv(
  "shiny-events.csv",
  stringsAsFactors = FALSE,
  col.names = c("guid", "app", "activity", "value", "datetime")
)
#>                                   guid         app  activity value
#> 1 225c7240-92c4-4cbc-bf4b-abdb7695621b shinyevents start_app    NA
#> 2 225c7240-92c4-4cbc-bf4b-abdb7695621b shinyevents    slider     3
#> 3 225c7240-92c4-4cbc-bf4b-abdb7695621b shinyevents  stop_app    NA
#>                  datetime
#> 1 2019-09-02 14:29:37 CDT
#> 2 2019-09-02 14:29:37 CDT
#> 3 2019-09-02 14:29:37 CDT
```

## Database example

`shiny_events_to_dbi` uses the `DBI` package to record events. Here are
a few highlights of how it works:

  - Uses the `dbWriteTable()` function, this allows it to work on most
    databases `DBI` is able to interact with
  - The `append = TRUE` argument is used. This allows the table to be
    created if it doesn’t exists yet, and only to add new records to the
    table, instead of overriding its content.
  - It creates, or expects, a table with the following names: `guid`,
    `app`, `datetime`, `activity`, `value`.

<!-- end list -->

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
#> 1 9a6466a1-a3c3-4e27-b70e-d3c93d11e481 shinyevents 2019-09-02 14:29:38 CDT
#> 2 9a6466a1-a3c3-4e27-b70e-d3c93d11e481 shinyevents 2019-09-02 14:29:38 CDT
#> 3 9a6466a1-a3c3-4e27-b70e-d3c93d11e481 shinyevents 2019-09-02 14:29:39 CDT
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
