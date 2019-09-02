
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyevents

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of `shinyevents` is to provide an easy way to log events
ocurring within a Shiny app. The logged events can later be analyzed to
help determine things such possible improvement oportunities for an app,
as well how end-users actually interact with the app itself.

## Installation

The development version pf `shinyevents` is available on
[GitHub](https://github.com/):

``` r
# install.packages("remotes")
remotes::install_github("edgararuiz/shinyevents")
```

This is a basic example which shows you how to solve a common problem:

``` r
library(shinyevents)

tracker <- shiny_events_to_csv()
```

``` r
tracker$app
#> [1] "shinyevents"
tracker$guid
#> [1] "0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd"
```

``` r
tracker$entry()
#> $guid
#> [1] "0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd"
#> 
#> $app
#> [1] "shinyevents"
#> 
#> $datetime
#> [1] "2019-09-01 19:35:47 CDT"
#> 
#> $activity
#> [1] ""
#> 
#> $value
#> [1] ""
```

``` r
tracker$event("example", "readme")
```

``` r
read_events <- function()  {
  read.csv(
  "shiny-events.csv",
  stringsAsFactors = FALSE,
  col.names = c("guid", "app", "activity", "value", "datetime")
  )
}
read_events()
#>                                   guid         app activity  value
#> 1 0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd shinyevents  example readme
#>                  datetime
#> 1 2019-09-01 19:35:47 CDT
```

``` r
tracker$event("start_app")
tracker$event("slider", "3")
tracker$event("stop_app")

read_events()
#>                                   guid         app  activity  value
#> 1 0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd shinyevents   example readme
#> 2 0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd shinyevents start_app       
#> 3 0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd shinyevents    slider      3
#> 4 0df0abb5-b4ae-4dd5-8f5a-92a5d7a083dd shinyevents  stop_app       
#>                  datetime
#> 1 2019-09-01 19:35:47 CDT
#> 2 2019-09-01 19:35:47 CDT
#> 3 2019-09-01 19:35:47 CDT
#> 4 2019-09-01 19:35:47 CDT
```

## Example

``` r
shiny::runApp(
  system.file(
    "samples", "shinydashboard-db", 
    package = "shinyevents"
    ), 
  display.mode = "normal"
  )
```
