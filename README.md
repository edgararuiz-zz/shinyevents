
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
#> [1] "119ced4a-2ecb-4aa1-8ca2-6e97205a9bd0"
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
